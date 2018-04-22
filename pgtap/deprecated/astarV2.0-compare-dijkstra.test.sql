/*PGR-GNU*****************************************************************

Copyright (c) 2015 pgRouting developers
Mail: project@pgrouting.org

------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

********************************************************************PGR-GNU*/

\i setup.sql

SELECT plan(2312);

SET client_min_messages TO ERROR;

UPDATE edge_table SET cost = cost + 0.001 * id * id, reverse_cost = reverse_cost + 0.001 * id * id;

CREATE or REPLACE FUNCTION astarCompareDijkstra(cant INTEGER default 17)
RETURNS SETOF TEXT AS
$BODY$
DECLARE
inner_sql TEXT;
inner_sql_d TEXT;
dijkstra_sql TEXT;
astar_sql TEXT;
BEGIN

    FOR i IN 1.. cant LOOP
        FOR j IN 1.. cant LOOP

            -- DIRECTED
            inner_sql := 'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, reverse_cost, x1, y1, x2, y2 FROM edge_table';
            dijkstra_sql := 'SELECT seq - 1::INTEGER, node::INTEGER, edge::INTEGER, cost FROM pgr_dijkstra($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true)';

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true, true)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);


            inner_sql_d := 'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, x1, y1, x2, y2 FROM edge_table';
            dijkstra_sql := 'SELECT seq - 1, node, edge, cost  FROM pgr_dijkstra($$' || inner_sql_d || '$$, ' || i || ', ' || j
                || ', true)';

            -- user contradiction
            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true, false)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);



            inner_sql := 'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, x1, y1, x2, y2 FROM edge_table';
            dijkstra_sql := 'SELECT seq - 1, node, edge, cost  FROM pgr_dijkstra($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true)';

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true, false)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', true, true)';
            RETURN query SELECT throws_ok(astar_sql);



            -- UNDIRECTED
            inner_sql := 'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, reverse_cost, x1, y1, x2, y2 FROM edge_table';
            dijkstra_sql := 'SELECT seq - 1, node, edge, cost  FROM pgr_dijkstra($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false)';

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false, true)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);

            dijkstra_sql := 'SELECT seq - 1, node, edge, cost  FROM pgr_dijkstra($$' || inner_sql_d || '$$, ' || i || ', ' || j
                || ', false)';

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false, false)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);



            inner_sql := 'SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, x1, y1, x2, y2 FROM edge_table';
            dijkstra_sql := 'SELECT seq - 1, node, edge, cost  FROM pgr_dijkstra($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false)';

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false, false)';
            RETURN query SELECT set_eq(astar_sql, dijkstra_sql, astar_sql);

            astar_sql := 'SELECT * FROM pgr_astar($$' || inner_sql || '$$, ' || i || ', ' || j
                || ', false, true)';
            RETURN query SELECT throws_ok(astar_sql);



        END LOOP;
    END LOOP;

    RETURN;
END
$BODY$
language plpgsql;

SELECT * from astarCompareDijkstra();


SELECT * FROM finish();
ROLLBACK;

