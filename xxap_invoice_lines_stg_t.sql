  -- +===========================================================================================
   --|                                    4i Apps
   --|                                    Chennai, India
   -- +===========================================================================================
   -- |
   -- |File name        : xxxap_invoice_lines_stg_t
   -- |Description      : Custom table for AP Invoice creation (Lines Details)
   -- |
   -- |Change Record:
   -- |===============
   -- |Version   Date         Author                   Remarks
   -- |========= ===========  ====================     ==============================
   -- |1.0       21-Oct-2024  Narendar V               Initial version
   -- +===========================================================================================
create table xxap_invoice_lines_stg
( stg_id             number,
  invoice_id         number,
  invoice_line_id    number,
  invoice_num        varchar2(20),
  line_num           number,
  line_amount        number,
  item_id            number,
  attribute_category varchar2(100),
  attribute1         varchar2(100),
  attribute2         varchar2(100),
  attribute3         varchar2(100),
  attribute4         varchar2(100),
  attribute5         varchar2(100),
  created_by         number,
  creation_date      date,
  last_updated_by    number,
  last_update_date   date,
  last_update_login  number
);
/