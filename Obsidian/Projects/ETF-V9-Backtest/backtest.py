import json
import pathlib
import traceback
import pandas as pd
import akshare as ak

ROOT = pathlib.Path(__file__).resolve().parent
CFG = json.loads((ROOT / 'config.json').read_text(encoding='utf-8'))
OUT = ROOT / 'reports'
OUT.mkdir(exist_ok=True)

def fetch(symbol):
    df = ak.fund_etf_hist_em(symbol=symbol, period='daily', start_date=CFG['start'], end_date=pd.Timestamp.today().strftime('%Y%m%d'), adjust='qfq')
    if df is None or df.empty:
        raise ValueError('empty ETF data')
    df = df.rename(columns={'日期':'date','开盘':'open','收盘':'close','最高':'high','最低':'low','成交量':'volume','成交额':'turnover'})
    df['date'] = pd.to_datetime(df['date'])
    for col in ['open','close','high','low','volume','turnover']:
        df[col] = pd.to_numeric(df[col], errors='coerce')
    return df.sort_values('date').dropna(subset=['open','close','high','low']).reset_index(drop=True)

def indicators(df, benchmark):
    d=df.copy()
    for n in (5,10,20,60):
        d[f'ma{n}']=d.close.rolling(n).mean()
    d['low60']=d.low.rolling(60).min()
    d['high60']=d.high.rolling(60).max()
    d['prior10close']=d.close.shift(1).rolling(10).max()
    d['v8']=(d.close>d.ma20)&(d.close.shift(1)>d.ma20.shift(1))&(d.close.shift(2)>d.ma20.shift(2))&(d.ma20>=d.ma20.shift(1))&(d.close>d.prior10close)
    b=benchmark[['date','close']].rename(columns={'close':'benchmark_close'})
    d=d.merge(b,on='date',how='left')
    d['benchmark_close']=d.benchmark_close.ffill()
    rel=d.close.pct_change(5)-d.benchmark_close.pct_change(5)
    recent_low=d.low.rolling(3).min()
    stopped=recent_low>=recent_low.shift(1)
    d['stop_ref']=d.low.rolling(5).min()*0.99
    risk=(d.close-d.stop_ref)/d.close
    space=d.high60/d.close-1
    d['v9']=(d.high60/d.low60-1>=0.12)&(d.close/d.low60-1<=0.12)&stopped&(d.close>d.ma10)&(d.ma5>d.ma5.shift(1))&(d.ma5.shift(1)>d.ma5.shift(2))&(rel>0)&(space>=0.12)&(risk>0)&(risk<=0.08)&(space/risk>=2.5)
    return d

def simulate(d, symbol, strategy):
    cash=float(CFG['capital']); qty=0; entry=0.; stop=0.; entry_i=-1; peak=0.; partial=False; trades=[]; equity=[]
    fee=lambda value:max(float(CFG['fee_min']),value*float(CFG['fee_rate']))
    slip=float(CFG['slippage'])
    for i,r in d.iterrows():
        if qty:
            peak=max(peak,float(d.iloc[i-1].close)) if i>entry_i else peak
            reason=None; price=None
            if r.low<=stop:
                price=min(float(r.open),stop)*(1-slip); reason='stop'
            elif i>entry_i and ((peak>0 and r.close<=peak*.93) or i-entry_i>=30):
                price=float(r.close)*(1-slip); reason='trail_or_time'
            elif not partial and i>entry_i and r.high>=entry*1.10:
                sell=min(qty,max(100,(qty//300)*100)); price=entry*1.10*(1-slip); reason='take_profit_1_3'; partial=True
                value=sell*price; cash+=value-fee(value); qty-=sell
                trades.append({'symbol':symbol,'strategy':strategy,'date':r.date.date().isoformat(),'action':'sell','reason':reason,'qty':sell,'price':round(price,5),'cash':round(cash,2)})
            if reason and reason!='take_profit_1_3' and qty:
                value=qty*price; cash+=value-fee(value)
                trades.append({'symbol':symbol,'strategy':strategy,'date':r.date.date().isoformat(),'action':'sell','reason':reason,'qty':qty,'price':round(price,5),'cash':round(cash,2)})
                qty=0; partial=False; peak=0
        if qty==0 and i>0 and bool(d.iloc[i-1][strategy]):
            price=float(r.open)*(1+slip)
            ref=float(d.iloc[i-1].stop_ref) if strategy=='v9' else price*.92
            distance=price-ref
            if price>0 and 0<distance/price<=.08:
                cap=min(1500,cash-fee(1500),300/(distance/price))
                buy=int(cap/price//100)*100
                if buy>=100 and buy*price+fee(buy*price)<=cash:
                    qty=buy; entry=price; stop=ref; entry_i=i; peak=float(r.close); partial=False
                    cash-=buy*price+fee(buy*price)
                    trades.append({'symbol':symbol,'strategy':strategy,'date':r.date.date().isoformat(),'action':'buy','reason':'prior_close_signal','qty':buy,'price':round(price,5),'cash':round(cash,2)})
        equity.append(cash+qty*float(r.close))
    if qty:
        # Mark to market; open positions remain open, not falsely recorded as realized profit.
        pass
    curve=pd.Series(equity,dtype=float)
    drawdown=(curve/curve.cummax()-1).min() if len(curve) else float('nan')
    return trades, {'symbol':symbol,'strategy':strategy,'bars':len(d),'signals':int(d[strategy].sum()),'orders':len(trades),'ending_equity_marked':round(equity[-1],2),'return_pct':round((equity[-1]/CFG['capital']-1)*100,2),'max_drawdown_pct':round(drawdown*100,2),'open_qty':qty}

def main():
    statuses=[]; all_trades=[]; all_summary=[]; all_signals=[]
    try:
        benchmark=fetch('510300')
    except Exception as e:
        raise RuntimeError('Benchmark 510300 download failed; abort instead of fabricating data') from e
    for symbol in CFG['symbols']:
        try:
            d=indicators(fetch(symbol),benchmark)
            for strategy in ('v8','v9'):
                trades,summary=simulate(d,symbol,strategy)
                all_trades.extend(trades);all_summary.append(summary)
            all_signals.extend([{'symbol':symbol,'date':r.date.date().isoformat(),'v8':bool(r.v8),'v9':bool(r.v9),'close':r.close} for _,r in d.iterrows() if r.v8 or r.v9])
            statuses.append({'symbol':symbol,'status':'ok','bars':len(d),'last_date':d.date.iloc[-1].date().isoformat()})
        except Exception as e:
            statuses.append({'symbol':symbol,'status':'error','message':str(e)})
            print(symbol,traceback.format_exc())
    pd.DataFrame(statuses).to_csv(OUT/'data_status.csv',index=False,encoding='utf-8-sig')
    pd.DataFrame(all_trades,columns=['symbol','strategy','date','action','reason','qty','price','cash']).to_csv(OUT/'trades.csv',index=False,encoding='utf-8-sig')
    pd.DataFrame(all_summary,columns=['symbol','strategy','bars','signals','orders','ending_equity_marked','return_pct','max_drawdown_pct','open_qty']).to_csv(OUT/'summary.csv',index=False,encoding='utf-8-sig')
    pd.DataFrame(all_signals,columns=['symbol','date','v8','v9','close']).to_csv(OUT/'signals.csv',index=False,encoding='utf-8-sig')
    if any(s['status']=='error' for s in statuses) or not all_summary:
        raise RuntimeError('Incomplete dataset; inspect data_status.csv, do not use as a verified backtest')
    print(pd.DataFrame(all_summary).to_string(index=False))

if __name__=='__main__':
    main()
