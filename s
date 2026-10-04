2026-10-05 00:47:56 | ERROR   | [confluence] combined publish step failed: name '_nexus_debug_fields' is not defined
2026-10-05 00:47:56 | ERROR   | [confluence] traceback: Traceback (most recent call last):
  File "/home/csecuser/scheduler/oss_checks/scheduler.py", line 668, in run_all
    publish_combined_confluence_report(config, run_date)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^
  File "/home/csecuser/scheduler/oss_checks/integrations/confluence/service.py", line 30, in publish_combined_confluence_report
    block = collect_version_confluence_payload(
        config, product, version, run_date
    )
  File "/home/csecuser/scheduler/oss_checks/integrations/confluence/collector/core.py", line 394, in collect_version_confluence_payload
    _custom_rules_check_rows_for_distrib(
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
        distrib_name=distrib.name,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^
    ...<5 lines>...
        nexus_compare_by_filename=nexus_compare_by_filename,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    )
    ^
  File "/home/csecuser/scheduler/oss_checks/integrations/confluence/collector/certification.py", line 524, in _custom_rules_check_rows_for_distrib
    nexus_fields = _nexus_debug_fields(nexus_compare_by_filename, filename)
                   ^^^^^^^^^^^^^^^^^^^
NameError: name '_nexus_debug_fields' is not defined

2026-10-05 00:47:56 | INFO    | [retention] [NDR / develop] removed old scan(s): 2026-10-02_20-39-21, 2026-10-02_14-53-27
2026-10-05 00:47:56 | INFO    | [retention] [NDR / 4.4] removed old scan(s): 2026-10-02_14-53-27
2026-10-05 00:47:56 | INFO    | run log written: /home/csecuser/results/2026-10-05/run.log
2026-10-05 00:47:56 | ERROR   | 2/2 scan(s) failed
2026-10-05 00:47:56 | ERROR   | [09_NDR] failed rc=1 after 4579.6s (76.3 min) — log: /home/csecuser/scan_logs/friday/09_NDR/2026-10-04_23-31-37.log
2026-10-05 00:47:56 | INFO    | ======================================================================
2026-10-05 00:47:56 | INFO    | friday batch finished in 4579.6s (76.3 min)
2026-10-05 00:47:56 | INFO    | Successful: 0/1
2026-10-05 00:47:56 | ERROR   | Failed: 1
2026-10-05 00:47:56 | ERROR   |   09_NDR.yml — rc=1 — 76.3 min — /home/csecuser/scan_logs/friday/09_NDR/2026-10-04_23-31-37.log
