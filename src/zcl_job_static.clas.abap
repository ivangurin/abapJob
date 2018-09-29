class zcl_job_static definition
  public
  final
  create public .

public section.

  type-pools abap .
  class-methods search
    importing
      !i_name type simple default '*'
      !i_user type simple default '*'
      !i_program type simple optional
      !i_planed type abap_bool default abap_false
      !i_active type abap_bool default abap_false
    preferred parameter i_name
    returning
      value(et_jobs) type tbtcjob_tt .
  class-methods delete
    importing
      !i_id type simple
      !i_name type simple
      !i_commit type abap_bool default abap_false
    raising
      zcx_generic .
protected section.
private section.
ENDCLASS.



CLASS ZCL_JOB_STATIC IMPLEMENTATION.


method delete.

  data l_count type tbtcjob-jobcount.
  l_count = i_id.

  data l_name type tbtcjob-jobname.
  l_name = i_name.

  call function 'BP_JOB_DELETE'
    exporting
      jobcount                 = l_count
      jobname                  = l_name
      forcedmode               = abap_false
      commitmode               = abap_false
    exceptions
      cant_delete_event_entry  = 1
      cant_delete_job          = 2
      cant_delete_joblog       = 3
      cant_delete_steps        = 4
      cant_delete_time_entry   = 5
      cant_derelease_successor = 6
      cant_enq_predecessor     = 7
      cant_enq_successor       = 8
      cant_enq_tbtco_entry     = 9
      cant_update_predecessor  = 10
      cant_update_successor    = 11
      commit_failed            = 12
      jobcount_missing         = 13
      jobname_missing          = 14
      job_does_not_exist       = 15
      job_is_eady_running   = 16
      no_delete_authority      = 17
      others                   = 18.
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

  if i_commit eq abap_true.
    zcl_abap_static=>commit( ).
  endif.

endmethod.


method search.

  check
    i_planed eq abap_true or
    i_active eq abap_true.

  data ls_criteria type btcselect.
  ls_criteria-jobname  = i_name.
  ls_criteria-username = i_user.
  ls_criteria-abapname = i_program.

  if i_planed eq abap_true.
    ls_criteria-prelim  = abap_true.
    ls_criteria-schedul = abap_true.
    ls_criteria-ready   = abap_true.
  endif.

  if i_active eq abap_true.
    ls_criteria-running = abap_true.
  endif.

  call function 'BP_JOB_SELECT'
    exporting
      jobselect_dialog    = zcl_abap_static=>no
      jobsel_param_in     = ls_criteria
    tables
      jobselect_joblist   = et_jobs
    exceptions
      invalid_dialog_type = 1
      jobname_missing     = 2
      no_jobs_found       = 3
      selection_canceled  = 4
      username_missing    = 5
      others              = 6.

endmethod.
ENDCLASS.
