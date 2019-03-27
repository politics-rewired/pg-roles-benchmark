begin;

create user big_group;

-- Create 1 million roles
select 'create user xy' || id || ' in role big_group;'
    from generate_series(1, (10^2)::int) as id;
\gexec

 -- Create large table
create table big_table as
select id
from generate_series(1, (10^3)::int) _(id);

-- Grant table-level access for roles
grant select on big_table to big_group;

-- Enable RLS
alter table big_table enable row level security;

create policy view_own on big_table for select using (('xy' || mod(id, (10^2)::int)) = current_user);

commit;
