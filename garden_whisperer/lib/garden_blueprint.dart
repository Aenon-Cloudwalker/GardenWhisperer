import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

enum MoistureLevel {
  DRY,
  MOIST,
  DAMP,
  WET,
  WATERLOGGED,
}

enum GardenMode { Soil, Moisture, Sunlight, Plants, AI, Notes, Harvest, Fertilizer, Season }

String getMoistureLevelDescriptor(MoistureLevel level) {
  switch (level) {
    case MoistureLevel.DRY:
      return "Dry";
    case MoistureLevel.MOIST:
      return "Moist";
    case MoistureLevel.DAMP:
      return "Damp";
    case MoistureLevel.WET:
      return "Wet";
    case MoistureLevel.WATERLOGGED:
      return "Waterlogged";
    default:
      return "";
  }
}

enum SunlightLevel {
  fullSun,
  partialSun,
  partialShade,
  fullShade,
}

String getSunlightLevelDescriptor(SunlightLevel level) {
  switch (level) {
    case SunlightLevel.fullSun:
      return 'Full Sun';
    case SunlightLevel.partialSun:
      return 'Partial Sun';
    case SunlightLevel.partialShade:
      return 'Partial Shade';
    case SunlightLevel.fullShade:
      return 'Full Shade';
    default:
      return '';
  }
}

Color getPlantAgeColor(PlantAge age) {
  switch (age) {
    case PlantAge.seedling:
      return Colors.green;
    case PlantAge.youngPlant:
      return Colors.yellow;
    case PlantAge.adultPlant:
      return Colors.orange;
    case PlantAge.maturePlant:
      return Colors.pink;
    case PlantAge.establishedPlant:
      return Colors.brown;
    case PlantAge.oldPlant:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

String getPlantAgeText(PlantAge age) {
  switch (age) {
    case PlantAge.seedling:
      return 'Seedling';
    case PlantAge.youngPlant:
      return 'Young Plant';
    case PlantAge.maturePlant:
      return 'Mature Plant';
    case PlantAge.adultPlant:
      return 'Adult Plant';
    case PlantAge.establishedPlant:
      return 'Established Plant';
    case PlantAge.oldPlant:
      return 'Old Plant';
    default:
      return '';
  }
}

double getMaturityPercentage(PlantAge age) {
  switch (age) {
    case PlantAge.seedling:
      return 0.2; // Adjust the percentage values according to your desired maturity levels
    case PlantAge.youngPlant:
      return 0.4;
    case PlantAge.maturePlant:
      return 0.6;
    case PlantAge.adultPlant:
      return 0.8;
    case PlantAge.establishedPlant:
      return 0.9;
    case PlantAge.oldPlant:
      return 1.0;
    default:
      return 0.0;
  }
}

class GardenBed {
  int rows;
  int columns;
  double tileSize;
  GardenMode currentMode;
  List<List<Tile>> tiles;
  List<Tile> selectedTiles = [];

  GardenBed({
    required this.rows,
    required this.columns,
    required this.tileSize,
    required this.currentMode,
    required this.tiles,
  });
}

class Tile {
  double sunlight;
  double moisture;
  SoilType soilType;
  List<Plant>? plants;
  bool isSelected;

  Tile({
    required this.sunlight,
    required this.moisture,
    required this.soilType,
    required this.plants,
    this.isSelected = false,
  });
}

enum SoilType {
  Clay,
  Sand,
  Loam,
  Silt,
}

enum PlantAge {
  seedling,
  youngPlant,
  maturePlant,
  adultPlant,
  establishedPlant,
  oldPlant,
}

class Plant {
  final String name;
  final String image;
  final String description;
  final int size;
  final PlantAge age;

  Plant({
    required this.name,
    required this.image,
    required this.description,
    required this.size,
    required this.age,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class GardenBedSettingsDialog extends StatefulWidget {
  final int initialRows;
  final int initialColumns;
  final double initialTileSize;
  final double minTileSize;
  final double maxTileSize;

  GardenBedSettingsDialog({
    required this.initialRows,
    required this.initialColumns,
    required this.initialTileSize,
    required this.minTileSize,
    required this.maxTileSize,
  });

  @override
  GardenBedSettingsDialogState createState() => GardenBedSettingsDialogState();
}

class GardenBedSettingsDialogState extends State<GardenBedSettingsDialog> {
  late TextEditingController _rowsController;
  late TextEditingController _columnsController;
  late TextEditingController _tileSizeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rowsController = TextEditingController(text: widget.initialRows.toString());
    _columnsController = TextEditingController(text: widget.initialColumns.toString());
    _tileSizeController = TextEditingController(text: widget.initialTileSize.toString());
  }

  @override
  void dispose() {
    _rowsController.dispose();
    _columnsController.dispose();
    _tileSizeController.dispose();
    super.dispose();
  }

  String? _validateInput(String? value, String label, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'Please enter the $label.';
    }
    double numericValue = double.tryParse(value) ?? 0.0;
    if (numericValue < min || numericValue > max) {
      return 'The $label must be between $min and $max.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Garden Bed Settings"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _rowsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Rows",
              ),
              validator: (value) => _validateInput(value, "rows", 1, double.infinity),
            ),
            TextFormField(
              controller: _columnsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Columns",
              ),
              validator: (value) => _validateInput(value, "columns", 1, double.infinity),
            ),
            TextFormField(
              controller: _tileSizeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Tile Size (cm)",
              ),
              validator: (value) => _validateInput(value, "tile size", widget.minTileSize, widget.maxTileSize),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              "Warning, changing garden settings will erase garden.",
              style: TextStyle(color: Colors.red, fontSize: 14),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              int rows = int.tryParse(_rowsController.text) ?? widget.initialRows;
              int columns = int.tryParse(_columnsController.text) ?? widget.initialColumns;
              double tileSize = double.tryParse(_tileSizeController.text) ?? widget.initialTileSize;
              Navigator.pop(
                context,
                {"rows": rows, "columns": columns, "tileSize": tileSize},
              );
            }
          },
          child: Text("Apply"),
        ),
      ],
    );
  }
}

class GardenBedDesigner extends StatefulWidget {
  @override
  _GardenBedDesignerState createState() => _GardenBedDesignerState();
}

class _GardenBedDesignerState extends State<GardenBedDesigner> {
  //can plants fit in tile?
  bool canPlantsFitInTile(double tileWidth, List<Plant>? plants) {
    if (plants == null || plants.isEmpty) {
      return true; // No plants to fit, consider it as fitting
    }

    double totalPlantsWidth = 0.0;
    int totalPlantsQuantity = 0;

    for (var plant in plants) {
      totalPlantsWidth += plant.size;
      totalPlantsQuantity = plants.length;
    }

    double availableSpace = tileWidth - totalPlantsWidth;

    return availableSpace >= 0 && totalPlantsQuantity > 0;
  }

  //scale settings
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset(0, 0);
  Offset _previousPosition = Offset(0, 0);

  bool selectAll = false;

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        //clear all and reselct all
        for (int i = 0; i < myGardenBed.rows; i++) {
          for (int b = 0; b < myGardenBed.columns; b++) {
            myGardenBed.selectedTiles.remove(myGardenBed.tiles[i][b]);
          }
        }
        for (int i = 0; i < myGardenBed.rows; i++) {
          for (int b = 0; b < myGardenBed.columns; b++) {
            myGardenBed.tiles[i][b].isSelected = true;
            myGardenBed.selectedTiles.add(myGardenBed.tiles[i][b]);
          }
        }
      } else {
        for (int i = 0; i < myGardenBed.rows; i++) {
          for (int b = 0; b < myGardenBed.columns; b++) {
            myGardenBed.tiles[i][b].isSelected = false;
            myGardenBed.selectedTiles.remove(myGardenBed.tiles[i][b]);
          }
        }
      }
    });
  }

  int rows = 5;
  int columns = 5;
  double tileSize = 50.0;

  GardenMode currentMode = GardenMode.Soil;
  GardenBed myGardenBed = GardenBed(
    rows: 5,
    columns: 5,
    tileSize: 50.0,
    currentMode: GardenMode.Soil,
    tiles: List.generate(5, (row) {
      return List.generate(5, (column) {
        return Tile(
          isSelected: false,
          sunlight: 0.0,
          moisture: 0.0,
          soilType: SoilType.Clay,
          plants: [],
        );
      });
    }),
  );

  Future<void> openSettingsDialog() async {
    Map<String, dynamic> result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return GardenBedSettingsDialog(
              initialRows: rows,
              initialColumns: columns,
              initialTileSize: tileSize,
              minTileSize: 40.0, // Replace with your minimum tile size
              maxTileSize: 300.0, // Replace with your maximum tile size
            );
          },
        ) ??
        {}; // Default result for cancellation

    if (result.isNotEmpty) {
      setState(() {
        rows = result["rows"] ?? myGardenBed.rows;
        columns = result["columns"] ?? myGardenBed.columns;
        tileSize = result["tileSize"] ?? myGardenBed.tileSize;

        // Update the myGardenBed object with the new dimensions
        myGardenBed = GardenBed(
          rows: rows,
          columns: columns,
          tileSize: tileSize,
          currentMode: currentMode,
          tiles: List.generate(rows, (row) {
            return List.generate(columns, (column) {
              return Tile(
                isSelected: false,
                sunlight: 0.0,
                moisture: 0.0,
                soilType: SoilType.Clay,
                plants: [],
              );
            });
          }),
        );
      });
    }
  }

  Widget buildSoilTile(int row, int column) {
    // Implement the soil tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle soil tile onTap event
      },
      child: Container(
        color: Colors.brown,
      ),
    );
  }

  Widget buildMoistureTile(int row, int column) {
    // Implement the moisture tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle moisture tile onTap event
      },
      child: Container(
        color: Colors.blue,
      ),
    );
  }

  Widget buildSunlightTile(int row, int column) {
    // Implement the sunlight tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle sunlight tile onTap event
      },
      child: Container(
        color: Colors.yellow,
      ),
    );
  }

  Widget buildPlantsTile(Plant plant, int row, int column) {
    return InkWell(
      onTap: () {
        // Handle the tap event for the plant tile
        print("hello");
      },
      child: Image.asset(
        plant.image,
        width: tileSize,
        height: tileSize,
      ),
    );
  }

  Widget buildAITile(int row, int column) {
    // Implement the AI tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle AI tile onTap event
      },
      child: Container(
        color: Colors.purple,
      ),
    );
  }

  Widget buildNotesTile(int row, int column) {
    // Implement the notes tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle notes tile onTap event
      },
      child: Container(
        color: Colors.orange,
      ),
    );
  }

  Widget buildHarvestTile(int row, int column) {
    // Implement the harvest tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle harvest tile onTap event
      },
      child: Container(
        color: Colors.red,
      ),
    );
  }

  Widget buildFertilizerTile(int row, int column) {
    // Implement the fertilizer tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle fertilizer tile onTap event
      },
      child: Container(
        color: Colors.yellow,
      ),
    );
  }

  Widget buildSeasonTile(int row, int column) {
    // Implement the season tile widget
    // This is just an example, customize it to your needs
    return GestureDetector(
      onTap: () {
        // Handle season tile onTap event
      },
      child: Container(
        color: Colors.orange,
      ),
    );
  }

  int countIdenticalPlants(List<Plant> plants, Plant referencePlant) {
    int count = 0;

    for (var plant in plants) {
      if (plant.name == referencePlant.name) {
        count++;
      }
    }

    return count;
  }

  List<List<Plant>> groupPlantsByAgeAndName(List<Plant> plants) {
    final groupedPlants = <List<Plant>>[];

    plants.forEach((plant) {
      bool foundGroup = false;

      for (var i = 0; i < groupedPlants.length; i++) {
        final group = groupedPlants[i];
        final firstPlant = group[0];

        if (plant.age == firstPlant.age && plant.name == firstPlant.name) {
          group.add(plant);
          foundGroup = true;
          break;
        }
      }

      if (!foundGroup) {
        groupedPlants.add([plant]);
      }
    });

    return groupedPlants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgroundtwoc.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.32),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  title: Text(
                    'Garden Bed Designer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Garden Bed Settings',
                        style: GoogleFonts.zcoolXiaoWei(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select a garden design mode:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<GardenMode>(
                              value: currentMode,
                              items: GardenMode.values.map((GardenMode mode) {
                                return DropdownMenuItem<GardenMode>(
                                  value: mode,
                                  child: Text(
                                    mode.toString().split('.').last,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (GardenMode? mode) {
                                if (mode != null) {
                                  setState(() {
                                    currentMode = mode;
                                  });
                                }
                              },
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Information'),
                                  content: Text('Here are the controls of the Garden Bed Designer:\n\n'
                                      '1. Zoom: Pinch two fingers to zoom in/out.\n'
                                      '2. Pan: Drag with one finger to pan the grid.\n'
                                      '3. Reset: Double-tap to reset the zoom and pan.\n'
                                      '4. Plant: Click on a plant to plant it in the selected tile.\n'
                                      '5.The progress indicator next to the plant indicates the level of maturity.\n\n'
                                      'Start designing your garden bed!'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Icon(Icons.info),
                            shape: CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: EdgeInsets.all(8.0),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(onPressed: openSettingsDialog, child: Text("Garden settings.")),
                          ElevatedButton(
                            onPressed: toggleSelectAll,
                            child: Text(selectAll ? 'Deselect All' : 'Select All'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (var row = 0; row < myGardenBed.rows; row++) {
                                  for (var column = 0; column < myGardenBed.columns; column++) {
                                    myGardenBed.tiles[row][column].plants = []; // Reset the plants list to an empty list
                                  }
                                }
                              });
                            },
                            child: Text("Clear all plants"),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      GestureDetector(
                        onScaleStart: (ScaleStartDetails details) {
                          _previousScale = _scale;
                          _previousPosition = details.focalPoint;
                        },
                        onScaleUpdate: (ScaleUpdateDetails details) {
                          setState(() {
                            _scale = _previousScale * details.scale;
                            _position += details.focalPoint - _previousPosition;
                            _previousPosition = details.focalPoint;
                          });
                        },
                        onDoubleTap: () {
                          setState(() {
                            _scale = 1.0;
                            _position = Offset(0, 0);
                          });
                        },
                        child: ClipRect(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..translate(_position.dx, _position.dy)
                              ..scale(_scale),
                            child: Container(
                              height: MediaQuery.of(context).size.height - 400,
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 1.5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  int row = index ~/ myGardenBed.columns;
                                  int column = index % myGardenBed.columns;

                                  switch (currentMode) {
                                    case GardenMode.Soil:
                                      return buildSoilTile(row, column);
                                    case GardenMode.Moisture:
                                      return buildMoistureTile(row, column);
                                    case GardenMode.Sunlight:
                                      return buildSunlightTile(row, column);
                                    case GardenMode.Plants:
                                      if (myGardenBed.tiles[row][column].plants != null && myGardenBed.tiles[row][column].plants!.isNotEmpty) {
                                        return InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            setState(() {
                                              // Toggle the selection of the tile
                                              myGardenBed.tiles[row][column].isSelected = !myGardenBed.tiles[row][column].isSelected;

                                              // Update the selectedTiles list
                                              if (myGardenBed.tiles[row][column].isSelected) {
                                                // Add the selected tile to the list
                                                myGardenBed.selectedTiles.add(myGardenBed.tiles[row][column]);
                                              } else {
                                                // Remove the deselected tile from the list
                                                myGardenBed.selectedTiles.remove(myGardenBed.tiles[row][column]);
                                              }
                                            });
                                          },
                                          child: Column(
                                            children: groupPlantsByAgeAndName(myGardenBed.tiles[row][column].plants!).map((groupedPlants) {
                                              final plant = groupedPlants[0];
                                              final plantCount = groupedPlants.length;
                                              final totalGroups = groupPlantsByAgeAndName(myGardenBed.tiles[row][column].plants!).length;
                                              final maturityPercentage = getMaturityPercentage(plant.age);

                                              return LayoutBuilder(
                                                builder: (context, constraints) {
                                                  final fontSize = constraints.maxWidth * 0.3 / totalGroups;
                                                  final imageSize = constraints.maxWidth * 1 / totalGroups;
                                                  final textColor = getPlantAgeColor(plant.age);

                                                  return Container(
                                                    color: myGardenBed.tiles[row][column].isSelected
                                                        ? Color.fromARGB(157, 105, 240, 175)
                                                        : Color.fromARGB(158, 76, 175, 79),
                                                    width: constraints.maxWidth,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Image.asset(
                                                            plant.image,
                                                            width: imageSize,
                                                            height: imageSize,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '$plantCount',
                                                                style: TextStyle(fontSize: fontSize, color: textColor),
                                                              ),
                                                              SizedBox(height: 4),
                                                              LinearProgressIndicator(
                                                                value: maturityPercentage,
                                                                backgroundColor: Colors.grey[300],
                                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      } else {
                                        return InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            setState(() {
                                              // Toggle the selection of the tile
                                              myGardenBed.tiles[row][column].isSelected = !myGardenBed.tiles[row][column].isSelected;

                                              // Update the selectedTiles list
                                              if (myGardenBed.tiles[row][column].isSelected) {
                                                // Add the selected tile to the list
                                                myGardenBed.selectedTiles.add(myGardenBed.tiles[row][column]);
                                              } else {
                                                // Remove the deselected tile from the list
                                                myGardenBed.selectedTiles.remove(myGardenBed.tiles[row][column]);
                                              }
                                            });
                                          },
                                          child: Container(
                                            color: myGardenBed.tiles[row][column].isSelected
                                                ? Color.fromARGB(157, 105, 240, 175)
                                                : Color.fromARGB(158, 76, 175, 79), // Set the background color to green
                                          ),
                                        );
                                      }
                                    case GardenMode.AI:
                                      return buildAITile(row, column);
                                    case GardenMode.Notes:
                                      return buildNotesTile(row, column);
                                    case GardenMode.Harvest:
                                      return buildHarvestTile(row, column);
                                    case GardenMode.Fertilizer:
                                      return buildFertilizerTile(row, column);
                                    case GardenMode.Season:
                                      return buildSeasonTile(row, column);
                                  }
                                },
                                itemCount: myGardenBed.rows * myGardenBed.columns,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tile Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            // Add your specific settings based on the current mode
                            // if (currentMode == GardenMode.Soil)
                            //   buildSoilSettings(),
                            if (currentMode == GardenMode.Moisture) buildMoistureSettings(),
                            if (currentMode == GardenMode.Sunlight) buildSunlightSettings(),
                            if (currentMode == GardenMode.Plants) buildPlantsSettings(myGardenBed),
                            // if (currentMode == GardenMode.AI) buildAISettings(),
                            // if (currentMode == GardenMode.Notes)
                            //   buildNotesSettings(),
                            // if (currentMode == GardenMode.Harvest)
                            //   buildHarvestSettings(),
                            // if (currentMode == GardenMode.Fertilizer)
                            //   buildFertilizerSettings(),
                            // if (currentMode == GardenMode.Season)
                            //   buildSeasonSettings(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget buildSoilSettings() {
      SoilType selectedSoilType = SoilType.Clay; // Default selected soil type

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          DropdownButton<SoilType>(
            value: selectedSoilType,
            items: SoilType.values.map((SoilType soilType) {
              return DropdownMenuItem<SoilType>(
                value: soilType,
                child: Text(
                  soilType.toString().split('.').last,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (SoilType? soilType) {
              if (soilType != null) {
                setState(() {
                  selectedSoilType = soilType;
                });
              }
            },
          ),
        ],
      );
    }
  }

  Widget buildMoistureSettings() {
    MoistureLevel selectedMoistureLevel = MoistureLevel.MOIST; // Default moisture level

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moisture Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        DropdownButton<MoistureLevel>(
          value: selectedMoistureLevel,
          onChanged: (MoistureLevel? newValue) {
            // Handle moisture level selection
            selectedMoistureLevel = newValue!;
            // Do something with the selected moisture level
          },
          items: MoistureLevel.values.map((MoistureLevel level) {
            return DropdownMenuItem<MoistureLevel>(
              value: level,
              child: Text(
                getMoistureLevelDescriptor(level),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSunlightSettings() {
    SunlightLevel selectedSunlightLevel = SunlightLevel.fullSun; // Default sunlight level

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sunlight Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        DropdownButton<SunlightLevel>(
          value: selectedSunlightLevel,
          onChanged: (SunlightLevel? newValue) {
            // Handle sunlight level selection
            selectedSunlightLevel = newValue!;
            // Do something with the selected sunlight level
          },
          items: SunlightLevel.values.map((SunlightLevel level) {
            return DropdownMenuItem<SunlightLevel>(
              value: level,
              child: Text(
                getSunlightLevelDescriptor(level),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  PlantAge selectedPlantAge = PlantAge.seedling;
  int plantQuantityValue = 1;

  Widget buildPlantsSettings(GardenBed myGardenBed) {
    List<Plant> plants = [
      Plant(
        name: 'Rose',
        image: 'assets/rose.png',
        description: 'Beautiful flowering plant with thorny stems.',
        size: 90,
        age: PlantAge.seedling,
      ),
      Plant(
        name: 'Roseinator',
        image: 'assets/rose.png',
        description: 'Beautiful flowering plant with thorny stems.',
        size: 90,
        age: PlantAge.seedling,
      ),
      Plant(
        name: 'Roseeatrix',
        image: 'assets/rose.png',
        description: 'Beautiful flowering plant with thorny stems.',
        size: 90,
        age: PlantAge.seedling,
      ),
      Plant(
        name: 'Sunflower',
        image: 'assets/sunflower.png',
        description: 'Tall plant with large yellow flowers that follow the sun.',
        size: 50,
        age: PlantAge.seedling,
      ),
      Plant(
        name: 'Tulip',
        image: 'assets/tulip.png',
        description: 'Colorful spring flower with cup-shaped petals.',
        size: 40,
        age: PlantAge.seedling,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plants Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        // Set an appropriate height for the GridView
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust the number of columns as needed
          ),
          itemCount: plants.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (myGardenBed.selectedTiles.isNotEmpty) {
                  setState(() {
                    for (int i = 0; i < myGardenBed.selectedTiles.length; i++) {
                      Tile currentTile = myGardenBed.selectedTiles[i];
                      currentTile.plants ??= []; // Initialize the list if it's null
                      if (currentTile.plants!.contains(plants[index])) {
                        // Plant is already present, remove it
                        for (int r = 0; r < plantQuantityValue; r++) {
                          currentTile.plants!.remove(plants[index]);
                        }
                      } else {
                        // Plant is not present, add it
                        bool canFit = true; // Flag to track if all plants can fit

                        for (int c = 0; c < plantQuantityValue; c++) {
                          if (canPlantsFitInTile(tileSize, currentTile.plants)) {
                            PlantAge selectedAge = selectedPlantAge;
                            Plant plant = Plant(
                              name: plants[index].name,
                              image: plants[index].image,
                              description: plants[index].description,
                              size: plants[index].size,
                              age: selectedAge,
                            );
                            currentTile.plants!.add(plant);
                            print(c);
                            print(plantQuantityValue);

                            print("it fits");
                            print(currentTile.plants);
                          } else {
                            print("it doesn't fit.");
                            canFit = false; // Set the flag to false if any plant cannot fit
                          }
                          print(currentTile.plants);
                        }

                        // Show dialog if plants cannot fit
                        if (!canFit) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Alert'),
                                content: Text('There is insufficient space in this tile.'),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    }
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 20,
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      child: Container(
                        child: Image.asset(plants[index].image),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Text(
                            plants[index].name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -15,
                      left: -5,
                      child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            if (myGardenBed.selectedTiles.isNotEmpty) {
                              setState(() {
                                for (int i = 0; i < myGardenBed.selectedTiles.length; i++) {
                                  Tile currentTile = myGardenBed.selectedTiles[i];
                                  currentTile.plants ??= []; // Initialize the list if it's null

                                  //  add it
                                  bool canFit = true; // Flag to track if all plants can fit

                                  for (int c = 0; c < plantQuantityValue; c++) {
                                    if (canPlantsFitInTile(tileSize, currentTile.plants)) {
                                      PlantAge selectedAge = selectedPlantAge;
                                      Plant plant = Plant(
                                        name: plants[index].name,
                                        image: plants[index].image,
                                        description: plants[index].description,
                                        size: plants[index].size,
                                        age: selectedAge,
                                      );
                                      currentTile.plants!.add(plant);
                                      print(c);
                                      print(plantQuantityValue);

                                      print("it fits");
                                      print(currentTile.plants);
                                    } else {
                                      print("it doesn't fit.");
                                      canFit = false; // Set the flag to false if any plant cannot fit
                                    }
                                    print(currentTile.plants);
                                  }

                                  // Show dialog if plants cannot fit
                                  if (!canFit) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Alert'),
                                          content: Text('There is insufficient space in this tile.'),
                                          actions: [
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              });
                            }
                          }),
                    ),
                    Positioned(
                      bottom: -15,
                      right: -5,
                      child: IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Remove button logic
                          if (myGardenBed.selectedTiles.isNotEmpty) {
                            setState(() {
                              for (int i = 0; i < myGardenBed.selectedTiles.length; i++) {
                                Tile currentTile = myGardenBed.selectedTiles[i];
                                currentTile.plants ??= []; // Initialize the list if it's null
                                if (currentTile.plants!.contains(plants[index])) {
                                  // Plant is already present, remove it
                                  for (int r = 0; r < plantQuantityValue; r++) {
                                    currentTile.plants!.remove(plants[index]);
                                  }
                                }
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    plantQuantityValue = int.tryParse(value) ?? 0; // Use int.tryParse to handle invalid inputs
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Plant quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 16),
            DropdownButton<PlantAge>(
              value: selectedPlantAge,
              onChanged: (PlantAge? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPlantAge = newValue;
                  });
                }
              },
              items: PlantAge.values.map((PlantAge age) {
                return DropdownMenuItem<PlantAge>(
                  value: age,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(right: 8),
                        color: getPlantAgeColor(age), // Replace with your color logic
                      ),
                      Text(getPlantAgeText(age)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}



// Widget buildAISettings() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'AI Settings',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       SizedBox(height: 16),
//       // Add your specific AI settings widgets here
//       CheckboxListTile(
//         value: isAIEnabled,
//         onChanged: (value) {
//           // Handle AI checkbox value change
//         },
//         title: Text('Enable AI'),
//       ),
//       Slider(
//         value: aiSensitivity,
//         min: 0,
//         max: 100,
//         onChanged: (value) {
//           // Handle AI sensitivity slider value change
//         },
//       ),
//     ],
//   );
// }

// Widget buildNotesSettings() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Notes Settings',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       SizedBox(height: 16),
//       // Add your specific notes settings widgets here
//       TextFormField(
//         decoration: InputDecoration(
//           labelText: 'Add Note',
//         ),
//         // Add logic to handle note input
//       ),
//       ElevatedButton(
//         onPressed: () {
//           // Handle note submission
//         },
//         child: Text('Save Note'),
//       ),
//     ],
//   );
// }

// Widget buildHarvestSettings() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Harvest Settings',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       SizedBox(height: 16),
//       // Add your specific harvest settings widgets here
//       Text(
//         'Ready for harvest: $isReadyForHarvest',
//       ),
//       ElevatedButton(
//         onPressed: () {
//           // Handle harvest action
//         },
//         child: Text('Harvest'),
//       ),
//     ],
//   );
// }

// Widget buildFertilizerSettings() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Fertilizer Settings',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       SizedBox(height: 16),
//       // Add your specific fertilizer settings widgets here
//       Slider(
//         value: fertilizerLevel,
//         min: 0,
//         max: 100,
//         onChanged: (value) {
//           // Handle fertilizer level slider value change
//         },
//       ),
//       TextFormField(
//         decoration: InputDecoration(
//           labelText: 'Fertilizer Type',
//         ),
//         // Add logic
//       ),
//       ElevatedButton(
//         onPressed: () {
//           // Apply fertilizer action
//         },
//         child: Text('Apply Fertilizer'),
//       ),
//     ],
//   );
// }

// Widget buildSeasonSettings() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Season Settings',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       SizedBox(height: 16),
//       // Add your specific season settings widgets here
//       DropdownButton<String>(
//         value: selectedSeason,
//         items: seasonOptions.map((String season) {
//           return DropdownMenuItem<String>(
//             value: season,
//             child: Text(season),
//           );
//         }).toList(),
//         onChanged: (value) {
//           // Handle season selection change
//         },
//       ),
//     ],
//   );
// }

