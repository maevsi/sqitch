BEGIN;

CREATE FUNCTION vibetype.create_contacts(contacts vibetype.contact[]) RETURNS SETOF vibetype.contact
    LANGUAGE sql STRICT
    AS $$
  INSERT INTO vibetype.contact(
    account_id,
    address_id,
    created_by,
    email_address,
    first_name,
    language,
    last_name,
    nickname,
    note,
    phone_number,
    time_zone,
    url
  )
  SELECT
    c.account_id,
    c.address_id,
    (SELECT vibetype.invoker_account_id()),
    c.email_address,
    c.first_name,
    c.language,
    c.last_name,
    c.nickname,
    c.note,
    c.phone_number,
    c.time_zone,
    c.url
  FROM unnest(contacts) AS c
  RETURNING *
$$;

COMMENT ON FUNCTION vibetype.create_contacts(vibetype.contact[]) IS 'Inserts multiple contacts for the invoker. Ids, timestamps and the creator passed in are ignored. Rows are not returned in input order.';

GRANT EXECUTE ON FUNCTION vibetype.create_contacts(vibetype.contact[]) TO vibetype_account;


CREATE FUNCTION vibetype.create_contact_groups(names TEXT[]) RETURNS SETOF vibetype.contact_group
    LANGUAGE sql STRICT
    AS $$
  INSERT INTO vibetype.contact_group(created_by, name)
  SELECT (SELECT vibetype.invoker_account_id()), n
  FROM unnest(names) AS n
  ON CONFLICT (created_by, lower(name)) DO NOTHING;

  SELECT g.*
  FROM vibetype.contact_group g
  WHERE g.created_by = (SELECT vibetype.invoker_account_id())
    AND lower(g.name) IN (SELECT lower(n) FROM unnest(names) AS n);
$$;

COMMENT ON FUNCTION vibetype.create_contact_groups(TEXT[]) IS 'Creates the contact groups of the invoker that do not exist yet, ignoring case, and returns all groups matching the names, existing ones included.';

GRANT EXECUTE ON FUNCTION vibetype.create_contact_groups(TEXT[]) TO vibetype_account;


CREATE FUNCTION vibetype.create_contact_group_members(contact_group_ids UUID[], contact_ids UUID[]) RETURNS SETOF vibetype.contact_group_member
    LANGUAGE sql STRICT
    AS $$
  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id)
  SELECT contact_group_id, contact_id
  FROM unnest(contact_group_ids, contact_ids) AS m(contact_group_id, contact_id)
  ON CONFLICT DO NOTHING
  RETURNING *
$$;

COMMENT ON FUNCTION vibetype.create_contact_group_members(UUID[], UUID[]) IS 'Pairs the group ids and contact ids by position and inserts the memberships that do not exist yet. Arrays of different lengths pad with NULL, which fails the whole call.';

GRANT EXECUTE ON FUNCTION vibetype.create_contact_group_members(UUID[], UUID[]) TO vibetype_account;

COMMIT;
