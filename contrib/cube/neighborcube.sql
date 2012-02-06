\c postgres
drop database if exists jaytest;
create database jaytest;
\c jaytest

create schema jaytest;
set search_path to jaytest;

\timing

create extension cube;

set work_mem to '1GB';
set maintenance_work_mem to '1GB';

create operator <-> (
  procedure = cube_distance,
  leftarg = cube,
  rightarg = cube,
  commutator = <->);

CREATE OR REPLACE FUNCTION g_cube_distance(internal, cube, integer, oid)
returns double precision
language c immutable strict
as '$libdir/cube';

alter operator family gist_cube_ops using gist add
  operator 15 <->(cube,cube) for order by float_ops,
  function 8 (cube,cube) g_cube_distance(internal,cube,integer,oid);


create table cubetest (
  position cube
  );

insert into cubetest (position)
  select cube(array[random() * 1000, random() * 1000, random() * 1000,random() * 1000, random() * 1000, random() * 1000]) from generate_series(1,10000000);
create index q on cubetest using gist(position);

select *, position <-> cube(array[500,500,500,500,500,500]) as p from cubetest order by p limit 10;
select *, position <-> cube(array[500,500,500,500,500,500]) as p from cubetest order by p limit 10;
select *, cube_distance(position, cube(array[500,500,500,500,500,500])) as p from cubetest order by p limit 10;