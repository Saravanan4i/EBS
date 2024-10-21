  -- +===========================================================================================
   --|                                    4i Apps
   --|                                    Chennai, India
   -- +===========================================================================================
   -- |
   -- |File name        : xxap_invoice_details_v
   -- |Description      : Custom View for AP Invoice Staging table.
   -- |
   -- |Change Record:
   -- |===============
   -- |Version   Date         Author                   Remarks
   -- |========= ===========  ====================     ==============================
   -- |1.0       21-Oct-2024  Narendar V               Initial version
   -- +===========================================================================================
create or replace view xxap_invoice_details_v
( row_id,
  invoice_id,
  invoice_num,
  invoice_date,
  invoice_amount,
  currency_code,
  header_description,
  org_id,
  operating_unit,
  header_attribute1,
  header_attribute2,
  header_attribute3,
  header_attribute4,
  header_attribute5,
  invoice_line_id,
  line_num,
  line_amount,
  item_id,
  line_attribute1,
  line_attribute2,
  line_attribute3,
  line_attribute4,
  line_attribute5
) as
select h.rowid,
       h.invoice_id,
       h.invoice_num,
       h.invoice_date,
       h.invoice_amount,
       h.currency_code,
       h.description,
       h.org_id,
       h.ou_name,
       h.attribute1,
       h.attribute2,
       h.attribute3,
       h.attribute4,
       h.attribute5,
       l.invoice_line_id,
       l.line_num,
       l.line_amount,
       l.item_id,
       l.attribute1,
       l.attribute2,
       l.attribute3,
       l.attribute4,
       l.attribute5
from   xxap_invoice_headers_stg h,
       xxap_invoice_lines_stg   l
where  nvl(h.invoice_id,1) = nvl(l.invoice_id,1)
and    h.invoice_num       = l.invoice_num;