-- Datasets table: tracks selectable data sources for the app
-- Each dataset points to a project hierarchy (project → sectors → AWCs → children)

CREATE TABLE IF NOT EXISTS datasets (
  id serial PRIMARY KEY,
  name text NOT NULL,
  name_te text,
  project_id int REFERENCES projects(id),
  district_id int REFERENCES districts(id),
  state_id int REFERENCES states(id),
  is_default boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- RLS: allow all authenticated users to read datasets
ALTER TABLE datasets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read datasets"
  ON datasets FOR SELECT
  USING (true);

-- Insert the existing app data as default dataset
-- (IDs will be determined after checking existing hierarchy)
-- INSERT INTO datasets (name, name_te, project_id, district_id, state_id, is_default)
-- SELECT 'App Data', 'యాప్ డేటా', p.id, p.district_id, d.state_id, true
-- FROM projects p JOIN districts d ON p.district_id = d.id
-- LIMIT 1;
