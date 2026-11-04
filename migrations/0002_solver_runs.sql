create table if not exists solver_runs (
  id         serial primary key,
  title      text not null,
  module     text not null,
  inputs     text not null,
  outputs    text not null,
  created_at timestamptz not null default now()
);

create index if not exists solver_runs_created_idx on solver_runs (created_at desc);
