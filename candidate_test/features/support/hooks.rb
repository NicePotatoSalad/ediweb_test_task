# Contains hooks like Before, After, AfterStep
# Aka conftest.py in pytest with written fixtures

# frozen_string_literal: true

Before do |_scenario|
  @scenario_data = ScenarioData.new
end
