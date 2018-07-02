-- Name: ListClosedActivitiesWithItems
-- Schema: posda_queries
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed', 'num_items']
-- Args: []
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

select
  distinct activity_id,
  brief_description,
  when_created,
  who_created,
  when_closed,
  count(distinct user_inbox_content_id) as num_items
from
  activity natural join activity_inbox_content
where when_closed is not null
group by activity_id, brief_description, when_created, who_created, when_closed
order by activity_id