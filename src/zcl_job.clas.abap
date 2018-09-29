class ZCL_JOB definition
  public
  final
  create public .

*"* public components of class ZCL_JOB
*"* do not include other source files here!!!
public section.

  data NAME type BTCJOB read-only .
  data ID type BTCJOBCNT read-only .
  data START_TIME type TIMESTAMP read-only .
  data IMMEDIATELY type ABAP_BOOL read-only .

  class-methods CREATE
    importing
      !I_NAME type SIMPLE
      !I_START_TIME type TIMESTAMP optional
      !I_IMMEDIATELY type ABAP_BOOL default ABAP_TRUE
    returning
      value(ER_JOB) type ref to ZCL_JOB
    raising
      ZCX_GENERIC .
  methods CONSTRUCTOR
    importing
      !I_NAME type SIMPLE
      !I_START_TIME type TIMESTAMP optional
      !I_IMMEDIATELY type ABAP_BOOL optional
    raising
      ZCX_GENERIC .
  methods START
    raising
      ZCX_GENERIC .
protected section.
*"* protected components of class ZCL_JOB
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_JOB
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_JOB IMPLEMENTATION.


method constructor.

  name        = i_name.
  start_time  = i_start_time.
  immediately = i_immediately.

  call function 'JOB_OPEN'
    exporting
      jobname          = name
    importing
      jobcount         = id
    exceptions
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      others           = 4.
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

endmethod.


method create.

  create object er_job
    exporting
      i_name        = i_name
      i_start_time  = i_start_time
      i_immediately = i_immediately.

endmethod.


method start.

  if start_time is initial.
    start_time = zcl_time_static=>get_timestamp( ).
  endif.

  data l_start_date type d.
  data l_start_time type t.
  convert time stamp start_time
    time zone zcl_time_static=>tz_system
    into date l_start_date time l_start_time.

  call function 'JOB_CLOSE'
    exporting
      jobcount             = id
      jobname              = name
      sdlstrtdt            = l_start_date
      sdlstrttm            = l_start_time
      strtimmed            = immediately
    exceptions
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      others               = 9.
  if sy-subrc ne 0.
    zcx_generic=>raise( ).
  endif.

endmethod.
ENDCLASS.
