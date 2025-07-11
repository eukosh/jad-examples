WITH leads_and_contacts_enriched AS (
    -- Scenario 1: A lead that was converted to a contact, plus a duplicate lead.
    SELECT
        'john.doe@example.com' AS email,
        'contact_123' AS contact_id,
        'lead_001' AS lead_id, -- This record represents the converted lead
        'acc_abc' AS account_id,
        'pro' AS profile_contract_type,
        NULL AS account_parent_account_id, -- This is a root account
        NULL AS account_parent_top_account_id,
        'contact_123' AS account_primary_contact_id, -- This is the primary contact
        TIMESTAMP('2023-02-20 11:30:00') AS created_on
    UNION ALL
    SELECT
        'john.doe@example.com' AS email,
        NULL AS contact_id, -- This is a duplicate lead that was never converted
        'lead_999' AS lead_id,
        NULL AS account_id,
        'trial' AS profile_contract_type,
        NULL AS account_parent_account_id,
        NULL AS account_parent_top_account_id,
        NULL AS account_primary_contact_id,
        TIMESTAMP('2023-01-15 10:00:00') AS created_on
    UNION ALL
    -- Scenario 2: A duplicated contact where we must choose based on hierarchy/recency.
    SELECT
        'jane.smith@example.com' AS email,
        'contact_456' AS contact_id,
        NULL AS lead_id,
        'acc_def' AS account_id,
        'standard' AS profile_contract_type,
        'parent_acc_789' AS account_parent_account_id, -- This is a child account (less preferred)
        'top_acc_xyz' AS account_parent_top_account_id,
        'contact_999' AS account_primary_contact_id, -- Not the primary contact
        TIMESTAMP('2022-11-10 09:00:00') AS created_on
    UNION ALL
    SELECT
        'jane.smith@example.com' AS email,
        'contact_789' AS contact_id,
        NULL AS lead_id,
        'acc_ghi' AS account_id,
        'pro' AS profile_contract_type,
        NULL AS account_parent_account_id, -- Root account (more preferred)
        NULL AS account_parent_top_account_id,
        'contact_789' AS account_primary_contact_id, -- Primary contact for this account
        TIMESTAMP('2023-03-01 14:00:00') AS created_on -- More recent
    UNION ALL
    -- Scenario 3: Two unconverted leads for the same email address.
    SELECT
        'peter.pan@example.com' AS email,
        NULL AS contact_id,
        'lead_003' AS lead_id,
        NULL AS account_id,
        'basic' AS profile_contract_type, -- Better contract type
        NULL AS account_parent_account_id,
        NULL AS account_parent_top_account_id,
        NULL AS account_primary_contact_id,
        TIMESTAMP('2023-04-05 16:00:00') AS created_on
    UNION ALL
    SELECT
        'peter.pan@example.com' AS email,
        NULL AS contact_id,
        'lead_004' AS lead_id,
        NULL AS account_id,
        'trial' AS profile_contract_type, -- Worse contract type
        NULL AS account_parent_account_id,
        NULL AS account_parent_top_account_id,
        NULL AS account_primary_contact_id,
        TIMESTAMP('2023-05-01 18:00:00') AS created_on -- More recent, but contract type takes precedence
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                LOWER(email)
            ORDER BY
                /* Rule 1: Contact before Lead */
                CASE WHEN contact_id IS NOT NULL THEN 1 ELSE 0 END DESC,

                /* Rule 2: Higher contract type first (pro > standard > basic > trial) */
                CASE
                    WHEN profile_contract_type = 'pro' THEN 4
                    WHEN profile_contract_type = 'standard' THEN 3
                    WHEN profile_contract_type = 'basic' THEN 2
                    WHEN profile_contract_type = 'trial' THEN 1
                    ELSE 0
                END DESC,

                /* Rule 3: Highest in hierarchy (root account is better) */
                -- A root/top-parent account has no parent.
                CASE
                    WHEN account_parent_account_id IS NULL AND account_parent_top_account_id IS NULL THEN 1
                    ELSE 0
                END DESC,

                /* Rule 4: Primary contact first */
                -- This check is only meaningful for contacts.
                CASE
                    WHEN account_primary_contact_id = contact_id THEN 1
                    ELSE 0
                END DESC,

                /* Rule 5: Most recently created record wins as the final tie-breaker */
                created_on DESC
        ) AS rn
    FROM leads_and_contacts_enriched
)

SELECT * EXCEPT (rn)
FROM ranked
WHERE rn = 1;
