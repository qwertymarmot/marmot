WBVardef today=@"select to_char(current_date,'mmddyyyy')";
WBExport -type=text
                 -file='C:/Shoutbomb/FTP/Holds/holds$[today].txt'
                 -delimiter='|'
		 -quotechar='"'
		 -quoteCharEscaping=escape
                 -lineEnding=crlf
                 -encoding=utf8;

SELECT
    bib_record_property.best_title AS title,
    to_char(rmi.record_last_updated_gmt,'MM-DD-YYYY') AS last_update, 
    'i' || rmi.record_num || 'a' AS item_no,
    'p' || rmp.record_num || 'a' AS patron_no, 
    h.pickup_location_code AS pickup_location,
    irp.barcode AS item_barcode,
    h.id AS hold_id

  FROM sierra_view.hold AS h
    RIGHT JOIN sierra_view.patron_record AS p
      ON ( p.id = h.patron_record_id )
    RIGHT JOIN sierra_view.record_metadata AS rmp
      ON (rmp.id = h.patron_record_id AND rmp.record_type_code = 'p')
    RIGHT JOIN sierra_view.item_record AS i
      ON ( i.id = h.record_id )
	RIGHT JOIN  sierra_view.item_record_property as irp
	  ON (irp.item_record_id = i.record_id)
    RIGHT JOIN sierra_view.bib_record_item_record_link AS bil
      ON ( bil.item_record_id = i.id AND bil.bibs_display_order = 0 )
    JOIN sierra_view.bib_record AS b
      ON ( b.id = bil.bib_record_id )
    JOIN sierra_view.bib_record_property
      ON (sierra_view.bib_record_property.bib_record_id = b.record_id)
    LEFT JOIN sierra_view.varfield AS bt
      ON ( bt.record_id = b.id AND bt.varfield_type_code = 't' AND bt.occ_num = 0 )
    LEFT JOIN sierra_view.varfield AS ic
      ON ( ic.record_id = i.id AND ic.varfield_type_code = 'c' AND ic.occ_num = 0 )
    LEFT JOIN sierra_view.record_metadata AS rmi
      ON ( rmi.id = i.id AND rmi.record_type_code = 'i')

  WHERE
    h.status in ('b','i','0')    
    AND i.item_status_code in ('!','#')
    AND h.pickup_location_code Is not null
	AND NOW() - rmi.record_last_updated_gmt > interval '3' hour

  ORDER BY
    patron_no;
