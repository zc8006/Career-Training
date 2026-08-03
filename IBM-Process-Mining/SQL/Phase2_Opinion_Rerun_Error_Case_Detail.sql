/*
IBM Process Mining 2.0.3
Phase2 意见征询后机器人录入报错 Case 明细（稳定版）

统一口径：
- Dashboard 过滤器：Phase2
- System <> DDD
- TrackerStatus = 审批结束
- 曾发生人工意见征询
- 人工后重新出现 BOT
- BOT 活动为“录入中发生错误”

时间处理规则（已在 IPM 2.0.3 弹性组件中实测通过）：
- STARTTIME 为毫秒 UNIX 时间戳
- 使用 sys.epoch(时间字段 / 1000)
- 使用 EXTRACT + || 拼接成文本
- 不使用 TO_TIMESTAMP、TO_CHAR、RIGHT、LPAD

说明：
原完整版本同时计算最后人工、最后BOT、Case最后事件，嵌套过深，
在 IPM 2.0.3 弹性组件中会出现“查询错误”。
本版先保留稳定可执行的核心字段、OCR、业务属性和 Comment 分类。
最后人工/最后BOT/Case最后事件应拆成独立组件验证后再逐步合并。
*/

SELECT
    result.CASEID AS "UUID",
    result."录入报错次数",

    EXTRACT(YEAR FROM sys.epoch(result."第一次报错时间" / 1000))
    || '-' ||
    EXTRACT(MONTH FROM sys.epoch(result."第一次报错时间" / 1000))
    || '-' ||
    EXTRACT(DAY FROM sys.epoch(result."第一次报错时间" / 1000))
    || ' ' ||
    EXTRACT(HOUR FROM sys.epoch(result."第一次报错时间" / 1000))
    || ':' ||
    EXTRACT(MINUTE FROM sys.epoch(result."第一次报错时间" / 1000))
    || ':' ||
    CAST(EXTRACT(SECOND FROM sys.epoch(result."第一次报错时间" / 1000)) AS INTEGER)
        AS "第一次报错时间",

    EXTRACT(YEAR FROM sys.epoch(result."最后一次报错时间" / 1000))
    || '-' ||
    EXTRACT(MONTH FROM sys.epoch(result."最后一次报错时间" / 1000))
    || '-' ||
    EXTRACT(DAY FROM sys.epoch(result."最后一次报错时间" / 1000))
    || ' ' ||
    EXTRACT(HOUR FROM sys.epoch(result."最后一次报错时间" / 1000))
    || ':' ||
    EXTRACT(MINUTE FROM sys.epoch(result."最后一次报错时间" / 1000))
    || ':' ||
    CAST(EXTRACT(SECOND FROM sys.epoch(result."最后一次报错时间" / 1000)) AS INTEGER)
        AS "最后一次报错时间",

    CASE
        WHEN result."录入报错次数" > 50 THEN '50次以上'
        WHEN result."录入报错次数" BETWEEN 11 AND 50 THEN '11至50次'
        WHEN result."录入报错次数" BETWEEN 4 AND 10 THEN '4至10次'
        WHEN result."录入报错次数" BETWEEN 2 AND 3 THEN '2至3次'
        ELSE '1次'
    END AS "报错次数区间",

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
      AND TRIM(scope_attr.System) <> 'DDD'
      AND TRIM(scope_attr.TrackerStatus) = '审批结束'

      AND TRIM(e.CASEID) IN (
          SELECT DISTINCT
              TRIM(manual_event.CASEID)

          FROM eventlog manual_event

          WHERE TRIM(manual_event.ROLE) = 'MANUAL'
            AND TRIM(manual_event.ACTIVITY) = '意见征询'
      )

    GROUP BY
        TRIM(e.CASEID)
) result

LEFT JOIN case_attributes_tbl_all attr
    ON result.CASEID = TRIM(attr.UUID)

LEFT JOIN manual_entry_classification1 classify
    ON result.CASEID = TRIM(classify.UUID)

GROUP BY
    result.CASEID,
    result."录入报错次数",
    result."第一次报错时间",
    result."最后一次报错时间"

ORDER BY
    result."录入报错次数" DESC;