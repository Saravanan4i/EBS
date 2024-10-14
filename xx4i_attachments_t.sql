--------------------------------------------------------------------------------
  -- Version  Date       Performer       Comments
  ----------  --------   --------------  ---------------------------------------
  -- 1.0      26-Sep-24  Narendar V      -- Initial Build
--------------------------------------------------------------------------------
create table xx4i_attachments
(attachment_id         number         default xx_attachment_id_s.nextval,
 pk1_id                number,
 pk1_value             varchar2(240),
 entity_type           varchar2(240),
 file_name             varchar2(240),
 description           varchar2(240),
 file_path             varchar2(1000),
 file_url              varchar2(1000),
 file_category_id      number,
 file_type             varchar2(10), 
 file_comment          varchar2(4000),
 attribute_category	   varchar2(240),
 attribute1        	   varchar2(240),
 attribute2        	   varchar2(240),
 attribute3            varchar2(240),
 attribute4        	   varchar2(240),
 attribute5        	   varchar2(240),
 created_by            number         not null,
 creation_date         date           not null,
 last_updated_by       number         not null,
 last_update_date      date           not null,
 last_update_login     number
);

alter table xx4i_attachments add constraints xx4i_attachments_pk primary key (attachment_id);

