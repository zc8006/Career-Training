SELECT
    tracker.UUID AS "UUID",

    timeline.TIMELINE AS "EVENT_COMMENT_TIMELINE",

    'System='
    || COALESCE(TRIM(tracker.System), '')

    || ' | OCRFeedback='
    || COALESCE(TRIM(tracker.OCRFeedback), '')

    || ' | TrackerStatus='
    || COALESCE(TRIM(tracker.TrackerStatus), '')

    || ' | ApplyStatus='
    || COALESCE(TRIM(tracker.ApplyStatus), '')

    || ' | ApplyType='
    || COALESCE(TRIM(tracker.ApplyType), '')

    || ' | POResult='
    || COALESCE(TRIM(tracker.POResult), '')

    || ' | POCompareResult='
    || COALESCE(TRIM(tracker.POCompareResult), '')

    || ' | PrepaymentResult='
    || COALESCE(TRIM(tracker.PrepaymentResult), '')

    || ' | ESignResult='
    || COALESCE(TRIM(tracker.ESignResult), '')

    || ' | ManualReviewResult='
    || COALESCE(TRIM(tracker.ManualReviewResult), '')

    || ' | ContractOrPO='
    || COALESCE(TRIM(tracker.ContractOrPO), '')

    || ' | Comment_Clean='
    || COALESCE(TRIM(tracker.Comment_Clean), '')

    || ' | IBMProcessor='
    || COALESCE(TRIM(tracker.IBMProcessor), '')

    || ' | IBMSupervisor='
    || COALESCE(TRIM(tracker.IBMSupervisor), '')
        AS "TRACKER_INFO"

FROM (
    /* Tracker按UUID去重，筛选OCRFeedback=EBS */
    SELECT
        TRIM(attr.UUID) AS UUID,

        MAX(TRIM(attr.System)) AS System,
        MAX(TRIM(attr.OCRFeedback)) AS OCRFeedback,
        MAX(TRIM(attr.TrackerStatus)) AS TrackerStatus,
        MAX(TRIM(attr.ApplyStatus)) AS ApplyStatus,
        MAX(TRIM(attr.ApplyType)) AS ApplyType,
        MAX(TRIM(attr.POResult)) AS POResult,
        MAX(TRIM(attr.POCompareResult)) AS POCompareResult,
        MAX(TRIM(attr.PrepaymentResult)) AS PrepaymentResult,
        MAX(TRIM(attr.ESignResult)) AS ESignResult,
        MAX(TRIM(attr.ManualReviewResult)) AS ManualReviewResult,
        MAX(TRIM(attr.ContractOrPO)) AS ContractOrPO,
        MAX(TRIM(attr.Comment_Clean)) AS Comment_Clean,
        MAX(TRIM(attr.IBMProcessor)) AS IBMProcessor,
        MAX(TRIM(attr.IBMSupervisor)) AS IBMSupervisor

    FROM case_attributes_tbl_all attr

    WHERE TRIM(attr.System) <> 'DDD'
      AND TRIM(attr.OCRFeedback) = 'EBS'
      AND attr.UUID IS NOT NULL
      AND TRIM(attr.UUID) <> ''

    GROUP BY
        TRIM(attr.UUID)
) tracker

INNER JOIN (
    SELECT
        eventlog.CASEID

    FROM eventlog

    WHERE eventlog.CASEID NOT IN (
        SELECT
            attr.UUID
        FROM case_attributes_tbl_all attr
        WHERE TRIM(attr.System) = 'DDD'
    )

    /* Event中必须存在审批结束 */
    AND eventlog.CASEID IN (
        SELECT DISTINCT
            e3.CASEID
        FROM eventlog e3
        WHERE TRIM(e3.ACTIVITY) = '审批结束'
    )

    /* Event中没有ChinaBot录入完成 */
    AND eventlog.CASEID NOT IN (
        SELECT DISTINCT
            e2.CASEID
        FROM eventlog e2
        WHERE TRIM(e2.ACTIVITY) = '录入完成'
          AND TRIM(e2.RESOURCE) IN (
              'ChinaBot',
              'ChinaBOT'
          )
    )

    /* Tracker中也没有被认定为RPA */
    AND eventlog.CASEID NOT IN (
        SELECT
            attr.UUID
        FROM case_attributes_tbl_all attr
        WHERE TRIM(attr.System) <> 'DDD'
          AND TRIM(attr.TrackerStatus) = '审批结束'
          AND TRIM(attr.IBMProcessor) IN (
              'ChinaBOT',
              'ChinaBot'
          )
    )

    GROUP BY
        eventlog.CASEID

    /* 必须存在审批外人工Activity */
    HAVING SUM(
        CASE
            WHEN TRIM(eventlog.ACTIVITY) NOT IN (
                '审批结束',
                '审批拒绝'
            )
             AND eventlog.RESOURCE IS NOT NULL
             AND TRIM(eventlog.RESOURCE) <> ''
             AND TRIM(eventlog.RESOURCE) NOT IN (
                 'ChinaBot',
                 'ChinaBOT'
             )
            THEN 1
            ELSE 0
        END
    ) > 0

) manual_case
    ON TRIM(manual_case.CASEID) = tracker.UUID

LEFT JOIN (
    SELECT
        timeline_data.UUID,

        GROUP_CONCAT(
            timeline_data.TIMELINE_TEXT,
            ' -> '
        ) AS TIMELINE

    FROM (
        SELECT
            ordered_data.UUID,
            ordered_data.SORT_TIME,
            ordered_data.SOURCE_ORDER,
            ordered_data.TIMELINE_TEXT

        FROM (
            /* Event */
            SELECT
                TRIM(e.CASEID) AS UUID,
                e.STARTTIME AS SORT_TIME,
                1 AS SOURCE_ORDER,

                TRIM(e.ACTIVITY)

                || CASE
                    WHEN e.RESOURCE IS NOT NULL
                     AND TRIM(e.RESOURCE) <> ''
                    THEN
                        '(' || TRIM(e.RESOURCE) || ')'
                    ELSE ''
                END AS TIMELINE_TEXT

            FROM eventlog e

            WHERE e.ACTIVITY IS NOT NULL
              AND TRIM(e.ACTIVITY) <> ''

            UNION ALL

            /* Comment */
            SELECT
                TRIM(cm.UUID) AS UUID,
                cm.Data AS SORT_TIME,
                2 AS SOURCE_ORDER,

                TRIM(cm.Status)

                || CASE
                    WHEN cm.Processor IS NOT NULL
                     AND TRIM(cm.Processor) <> ''
                    THEN
                        '(' || TRIM(cm.Processor) || ')'
                    ELSE ''
                END AS TIMELINE_TEXT

            FROM comments_detail_tbl cm

            WHERE cm.Status IS NOT NULL
              AND TRIM(cm.Status) <> ''
        ) ordered_data

        ORDER BY
            ordered_data.UUID,
            ordered_data.SORT_TIME,
            ordered_data.SOURCE_ORDER
    ) timeline_data

    GROUP BY
        timeline_data.UUID
) timeline
    ON timeline.UUID = tracker.UUID

ORDER BY
    tracker.UUID

LIMIT 150 OFFSET 0;
