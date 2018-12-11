// To get average NDVI for census tracts


// Census tract polygons
var table = ee.FeatureCollection("TIGER/2010/Tracts_DP1");
// Landsat imagery
var LS8 = ee.ImageCollection("LANDSAT/LC8_L1T_TOA")
// Filter to data range
var LS_15 = LS8.filterDate('2015-01-01', '2015-12-31');
//--------------------------------------------------------------
//--------------------------------------------------------------
// NDVI function
var addNDVI = function(image) {
  var ndvi = image.normalizedDifference(['B5', 'B4']).rename('NDVI');
  return image.addBands(ndvi);
};

// map over collection
var withNDVI = LS_15.map(addNDVI);


// Make a "greenest" pixel composite.
var greenest = withNDVI.qualityMosaic('NDVI');

// Get just the NDVI value band
var val_NDVI = greenest.select('NDVI')

// Map.addLayer(val_NDVI,{min: -1, max: 1, palette: ['brown', 'yellow', 'green']})

//--------------------------------------------------------------
//--------------------------------------------------------------
// Get elevation to mask 0
var elevation = ee.Image("USGS/SRTMGL1_003") // elevation data

// apply mask    
var wmask = val_NDVI.mask(elevation.neq(0))

// Map.addLayer(wmask,{min: -1, max: 1, palette: ['brown', 'yellow', 'green']},'NDVImask')

//--------------------------------------------------------------

// Filter to get only one state
// https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code
// var ftrct =  table.filter(ee.Filter.stringStartsWith('geoid10', '19'));

// or just reduce the number of columns
// var ftrct = table.select("geoid10")
// run on 2 states at a time
var c1 = table.filter(ee.Filter.stringStartsWith('geoid10', '55'))
var c2 = table.filter(ee.Filter.stringStartsWith('geoid10', '56'))
var ftrct = c1.merge(c2)

print('Count after filter:', ftrct.size());

//--------------------------------------------------------------
// Map over feature collection, get mean and std dev
var meanTRndvi = wmask.reduceRegions({
  collection: ftrct,
  reducer: ee.Reducer.mean().setOutputs(['ndvi_mean']).combine({
		reducer2: ee.Reducer.stdDev().setOutputs(['ndvi_sd']),
    sharedInputs: true
  }),
  scale: 30 // 30 meters for Landsat
});

// Print the first to check, just the first 6 elements
// print(meanTRndvi.toList(6))

//--------------------------------------------------------------

// drop .geo
var ndviOut = meanTRndvi.select(['.*'], null, false);
var ndviOut2 = ndviOut.select(["geoid10", "ndvi_mean", "ndvi_sd"]);
// export to google drive, can add state GEOID on export
Export.table.toDrive({
  collection: ndviOut2, 
  description: 'tract_15green_st_', 
  folder: 'RemoteSensingWork', 
//fileNamePrefix: , 
  fileFormat: 'CSV'
  }); 
