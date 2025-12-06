BEGIN;

-- contact table policies
DROP POLICY contact_select ON vibetype.contact;
DROP POLICY contact_insert ON vibetype.contact;
DROP POLICY contact_update ON vibetype.contact;

CREATE POLICY contact_select ON vibetype.contact FOR SELECT
USING (
  (
    contact.account_id = vibetype.invoker_account_id()
    AND
    NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.created_by
    )
  )
  OR
  (
    contact.created_by = vibetype.invoker_account_id()
    AND
    NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.account_id
    )
  )
  OR contact.id IN (SELECT vibetype.guest_contact_ids())
);

CREATE POLICY contact_insert ON vibetype.contact FOR INSERT
WITH CHECK (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (
    SELECT 1
    FROM vibetype.account_block b
    WHERE b.created_by = vibetype.invoker_account_id()
      AND b.blocked_account_id = contact.account_id
  )
);

CREATE POLICY contact_update ON vibetype.contact FOR UPDATE
USING (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (
    SELECT 1
    FROM vibetype.account_block b
    WHERE b.created_by = vibetype.invoker_account_id()
      AND b.blocked_account_id = contact.account_id
  )
);

-- address table policies
DROP POLICY address_all ON vibetype.address;

CREATE POLICY address_all ON vibetype.address FOR ALL
USING (
  (
    address.created_by = vibetype.invoker_account_id()
    OR
    address.id IN (SELECT address_id FROM vibetype_private.event_policy_select())
  )
  AND
  NOT EXISTS (
    SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = address.created_by
  )
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

-- account table policies
DROP POLICY account_select ON vibetype.account;

CREATE POLICY account_select ON vibetype.account FOR SELECT USING (
  NOT EXISTS (
    SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = account.id
  )
);

-- guest table policies
DROP POLICY guest_select ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;

CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
    -- Display guests accessible through guest claims.
    guest.id = ANY (vibetype.guest_claim_array())
  OR
  (
    -- Display guests where the contact is the invoker account.
    guest.contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE account_id = vibetype.invoker_account_id()
        -- omit contacts created by a user who is blocked by the invoker
        -- omit contacts created by a user who blocked the invoker.
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.created_by
        )
    )
  )
  OR
  (
    -- Display guests to events organized by the invoker,
    -- but omit guests with contacts pointing at a user blocked by the invoker or pointing at a user who blocked the invoker.
    -- Also omit guests created by a user blocked by the invoker or created by a user who blocked the invoker.
    guest.event_id IN (SELECT vibetype.events_organized())
    AND
      guest.contact_id IN (
        SELECT c.id
        FROM vibetype.contact c
        WHERE
          NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
          )
          AND
          NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
          )
      )
  )
);

CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
    guest.event_id IN (SELECT vibetype.events_organized())
  AND
  (
    vibetype.event_guest_count_maximum(guest.event_id) IS NULL
    OR
    vibetype.event_guest_count_maximum(guest.event_id) > vibetype.guest_count(guest.event_id)
  )
  AND
    guest.contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE created_by = vibetype.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM vibetype.contact c
        JOIN vibetype.account_block b
        ON
          c.account_id = b.blocked_account_id
          AND
          c.created_by = b.created_by
      WHERE
        c.created_by = vibetype.invoker_account_id()
    )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
    guest.id = ANY (vibetype.guest_claim_array())
  OR
  (
    guest.contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE account_id = vibetype.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM vibetype.contact c
        JOIN vibetype.account_block b ON c.account_id = b.created_by AND c.created_by = b.blocked_account_id
      WHERE c.account_id = vibetype.invoker_account_id()
    )
  )
  OR
  (
    guest.event_id IN (SELECT vibetype.events_organized())
    AND
    -- omit contacts created by a blocked account or referring to a blocked account
    guest.contact_id IN (
      SELECT c.id
      FROM vibetype.contact c
      WHERE
        NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
        )
    )
  )
);

-- friendship table policies
DROP POLICY friendship_existing ON vibetype.friendship;

CREATE POLICY friendship_existing ON vibetype.friendship FOR ALL
USING (
  (
    vibetype.invoker_account_id() = friendship.a_account_id
    AND NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = friendship.b_account_id
    )
  )
  OR
  (
    vibetype.invoker_account_id() = friendship.b_account_id
    AND NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = friendship.a_account_id
    )
  )
)
WITH CHECK (FALSE);

-- guest_claim_array function
CREATE OR REPLACE FUNCTION vibetype.guest_claim_array()
RETURNS UUID[] AS $$
DECLARE
  _guest_ids UUID[];
  _guest_ids_unblocked UUID[] := ARRAY[]::UUID[];
BEGIN
  _guest_ids := string_to_array(replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''), ',')::UUID[];

  IF _guest_ids IS NOT NULL THEN
    _guest_ids_unblocked := ARRAY (
      SELECT g.id
      FROM vibetype.guest g
        JOIN vibetype.event e ON g.event_id = e.id
        JOIN vibetype.contact c ON g.contact_id = c.id
      WHERE g.id = ANY(_guest_ids)
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
        )
    );
  ELSE
    _guest_ids_unblocked := ARRAY[]::UUID[];
  END IF;
  RETURN _guest_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

-- guest_contact_ids function
CREATE OR REPLACE FUNCTION vibetype.guest_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    -- get all contacts of guests
    SELECT g.contact_id
    FROM vibetype.guest g
    WHERE
      (
        -- that are known through a guest claim
        g.id = ANY (vibetype.guest_claim_array())
      OR
        -- or for events organized by the invoker
        g.event_id IN (SELECT vibetype.events_organized())
        and g.contact_id IN (
          SELECT id
          FROM vibetype.contact
          WHERE
            NOT EXISTS (
              SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.created_by
            )
            AND NOT EXISTS (
              SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.account_id
            )
        )
      );
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

-- events_invited function
CREATE OR REPLACE FUNCTION vibetype_private.events_invited()
RETURNS TABLE(event_id uuid) AS $$
BEGIN
  RETURN QUERY

  -- get all events for guests
  SELECT g.event_id FROM vibetype.guest g
  WHERE
    (
      -- whose event ...
      g.event_id IN (
        SELECT id
        FROM vibetype.event
        WHERE
          -- is not created by ...
          NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = event.created_by
          )
      )
      AND
      -- whose invitee
      g.contact_id IN (
        SELECT id
        FROM vibetype.contact
        WHERE
            -- is the requesting user
            account_id = vibetype.invoker_account_id()
          AND
            -- who is not invited by
            NOT EXISTS (
              SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.created_by
            )
      )
    )
    OR
      -- for which the requesting user knows the id
      g.id = ANY (vibetype.guest_claim_array());
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

-- event_policy_select function
CREATE OR REPLACE FUNCTION vibetype_private.event_policy_select()
RETURNS SETOF vibetype.event AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM vibetype.event e
    WHERE (
      (
        e.visibility = 'public'
        AND (
          e.guest_count_maximum IS NULL
          OR e.guest_count_maximum > vibetype.guest_count(e.id)
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
        )
      )
      OR (
        e.id IN (
          SELECT * FROM vibetype_private.events_invited()
        )
      )
    );
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

COMMIT;
