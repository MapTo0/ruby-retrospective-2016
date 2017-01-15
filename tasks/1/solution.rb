CELSIUS_COEFFICIENTS = {
  "C" => {
    "to_celsius" => -> (degrees) { degrees },
    "celsius_to_unit" => -> (degrees) { degrees }
  },
  "F" => {
    "celsius_to_unit" => -> (degrees) { degrees * 1.8 + 32 },
    "to_celsius" => -> (degrees) { (degrees - 32) / 1.8 }
  },
  "K" => {
    "celsius_to_unit" => -> (celsius) { celsius + 273.15 },
    "to_celsius" => -> (degrees) { degrees - 273.15 }
  }
}

SUBSTANCES = {
  'water'   => { melting_point: 0,     boiling_point: 100   },
  'ethanol' => { melting_point: -114,  boiling_point: 78.37 },
  'gold'    => { melting_point: 1_064, boiling_point: 2_700 },
  'silver'  => { melting_point: 961.8, boiling_point: 2_162 },
  'copper'  => { melting_point: 1_085, boiling_point: 2_567 }
}

def convert_between_temperature_units(degrees, convert_from_unit, convert_to_unit)
  celsius = CELSIUS_COEFFICIENTS[convert_from_unit]["to_celsius"].call(degrees)
  CELSIUS_COEFFICIENTS[convert_to_unit]["celsius_to_unit"].call(celsius)
end

def melting_point_of_substance(substance, unit)
  convert_between_temperature_units(SUBSTANCES[substance][:melting_point], "C", unit)
end

def boiling_point_of_substance(substance, unit)
  convert_between_temperature_units(SUBSTANCES[substance][:boiling_point], "C", unit)
end