/*
IBM Process Mining 2.0.3
Phase2 意见征询后机器人录入报错 Case 明细

统一口径：
- Dashboard 过滤器：Phase2
- System <> DDD
- TrackerStatus = 审批结束
- 曾发生人工意见征询
- 人工后重新出现 BOT
- BOT 活动为“录入中发生错误”

时间处理规则：
IPM 2.0.3 使用 MonetDB 语法。
事件时间是毫秒 UNIX 时间戳，必须使用：
    sys.epoch(时间字段 / 1000)
不要使用 TO_TIMESTAMP / TO_CHAR。
在 Elastic Widget 中将时间列类型设置为 datetime。
*/

SELECT
    result.CASEID AS "UUID",
    result."录入报错次数",

    sys.epoch(result."第一次报错时间" / 1000)
        AS "第一次报错时间",

    sys.epoch(result."最后一次报错时间" / 1000)
        AS "最后一次报错时间",

    CASE
        WHEN result."录入报错次数" > 50 THEN '50次以上'
        WHEN result."录入报错次数" BETWEEN 11 AND 50 THEN '11至50次'
        WHEN result."录入报错次数" BETWEEN 4 AND 10 THEN '4至10次'
        WHEN result."录入报错次数" BETWEEN 2 AND 3 THEN '2至3次'
        ELSE '1次'
    END AS "报错次数区间",

    last_manual."最后人工活动",
    sys.epoch(last_manual."最后人工时间" / 1000)
        AS "最后人工时间",

    last_bot."最后机器人活动",
    sys.epoch(last_bot."最后机器人时间" / 1000)
        AS "最后机器人时间",

    last_case."Case最后活动",
    last_case."Case最后角色",
    sys.epoch(last_case."Case最后时间" / 1000)
        AS "Case最后时间",

    MAX(TRIM(attr.System)) AS "系统",
    MAX(TRIM(attr.OCRFeedback)) AS "OCR反馈",
    MAX(TRIM(attr.TrackerStatus)) AS "Tracker状态",
    MAX(TRIM(attr.POResult)) AS "PO结果",
    MAX(TRIM(attr.POCompareResult)) AS "PO对比结果",
    MAX(TRIM(attr.ESignResult)) AS "电子签章结果",

    MAX(TRIM(classify.CLEAN_ED)) AS "Clean分类",
    MAX(TRIM(classify.COMMENTS_ED)) AS "Comments分类",
    MAX(TRIM(classify.Status)) AS "Comment状态",
    MAX(TRIM(classify.MESSAGES)) AS "Messages",
    MAX(TRIM(attr.Comment_Clean)) AS "清洗后备注"

FROM (
    SELECT
        TRIM(e.CASEID) AS CASEID,
        COUNT(*) AS "录入报错次数",
        MIN(e.STARTTIME) AS "第一次报错时间",
        MAX(e.STARTTIME) AS "最后一次报错时间"

    FROM eventlog e

    INNER JOIN bot_recovery_case_tbl recovery
        ON TRIM(e.CASEID) = TRIM(recovery.UUID)

    INNER JOIN case_attributes_tbl_all scope_attr
        ON TRIM(e.CASEID) = TRIM(scope_attr.UUID)

    WHERE TRIM(e.ROLE) = 'BOT'
      AND TRIM(e.ACTIVITY) = '录入中发生错误'
      AND recovery.HAS_MANUAL_TO_BOT = 1
      AND e.STARTTIME > recovery.FIRST_MANUAL_TIME
      AND COALESCE(TRIM(scope_attr.System), '') <> 'DDD'
      AND TRIM(scope_attr.TrackerStatus) = '审批结束'

      AND TRIM(e.CASEID) IN (
          SELECT DISTINCT TRIM(manual_event.CASEID)
          FROM eventlog manual_event
          WHERE TRIM(manual_event.ROLE) = 'MANUAL'
            AND TRIM(manual_event.ACTIVITY) = '意见征询'
      )

    GROUP BY TRIM(e.CASEID)
) result

LEFT JOIN (
    SELECT
        manual_time.CASEID,
        manual_time."最后人工时间",
        MAX(TRIM(manual_event.ACTIVITY)) AS "最后人工活动"

    FROM (
        SELECT
            TRIM(e1.CASEID) AS CASEID,
            MAX(e1.STARTTIME) AS "最后人工时间"
        FROM eventlog e1
        WHERE TRIM(e1.ROLE) = 'MANUAL'
        GROUP BY TRIM(e1.CASEID)
    ) manual_time

    INNER JOIN eventlog manual_event
        ON TRIM(manual_event.CASEID) = manual_time.CASEID
       AND manual_event.STARTTIME = manual_time."最后人工时间"
       AND TRIM(manual_event.ROLE) = 'MANUAL'

    GROUP BY manual_time.CASEID, manual_time."最后人工时间"
) last_manual
    ON result.CASEID = last_manual.CASEID

LEFT JOIN (
    SELECT
        bot_time.CASEID,
        bot_time."最后机器人时间",
        MAX(TRIM(bot_event.ACTIVITY)) AS "最后机器人活动"

    FROM (
        SELECT
            TRIM(e2.CASEID) AS CASEID,
            MAX(e2.STARTTIME) AS "最后机器人时间"
        FROM eventlog e2
        WHERE TRIM(e2.ROLE) = 'BOT'
        GROUP BY TRIM(e2.CASEID)
    ) bot_time

    INNER JOIN eventlog bot_event
        ON TRIM(bot_event.CASEID) = bot_time.CASEID
       AND bot_event.STARTTIME = bot_time."最后机器人时间"
       AND TRIM(bot_event.ROLE) = 'BOT'

    GROUP BY bot_time.CASEID, bot_time."最后机器人时间"
) last_bot
    ON result.CASEID = last_bot.CASEID

LEFT JOIN (
    SELECT
        case_time.CASEID,
        case_time."Case最后时间",
        MAX(TRIM(case_event.ACTIVITY)) AS "Case最后活动",
        MAX(TRIM(case_event.ROLE)) AS "Case最后角色"

    FROM (
        SELECT
            TRIM(e3.CASEID) AS CASEID,
            MAX(e3.STARTTIME) AS "Case最后时间"
        FROM eventlog e3
        GROUP BY TRIM(e3.CASEID)
    ) case_time

    INNER JOIN eventlog case_event
        ON TRIM(case_event.CASEID) = case_time.CASEID
       AND case_event.STARTTIME = case_time."Case最后时间"

    GROUP BY case_time.CASEID, case_time."Case最后时间"
) last_case
    ON result.CASEID = last_case.CASEID

LEFT JOIN case_attributes_tbl_all attr
    ON result.CASEID = TRIM(attr.UUID)

LEFT JOIN manual_entry_classification1 classify
    ON result.CASEID = TRIM(classify.UUID)

GROUP BY
    result.CASEID,
    result."录入报错次数",
    result."第一次报错时间",
    result."最后一次报错时间",
    last_manual."最后人工活动",
    last_manual."最后人工时间",
    last_bot."最后机器人活动",
    last_bot."最后机器人时间",
    last_case."Case最后活动",
    last_case."Case最后角色",
    last_case."Case最后时间"

ORDER BY result."录入报错次数" DESC;
