  -- +===========================================================================================
   --|                                    4i Apps
   --|                                    Chennai, India
   -- +===========================================================================================
   -- |
   -- |File name        : xxxap_invoice_headers_stg_t
   -- |Description      : Custom table for AP Invoice creation (Header Details)
   -- |
   -- |Change Record:
   -- |===============
   -- |Version   Date         Author                   Remarks
   -- |========= ===========  ====================     ==============================
   -- |1.0       21-Oct-2024  Narendar V               Initial version
   -- +===========================================================================================
create table xxap_invoice_headers_stg
( stg_id             number,
  invoice_id         number,
  invoice_num        varchar2(20),
  invoice_date       date,
  invoice_amount     number,
  currency_code      varchar2(20),
  description        varchar2(100),
  org_id             number,
  attribute_category varchar2(100),
  attribute1         varchar2(100),
  attribute2         varchar2(100),
  attribute3         varchar2(100),
  attribute4         varchar2(100),
  attribute5         varchar2(100),
  ou_name            varchar2(100),
  created_by         number,
  creation_date      date,
  last_updated_by    number,
  last_update_date   date,
  last_update_login  number
);
-- +
