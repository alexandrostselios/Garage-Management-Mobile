import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:garage_management/models/carEngineType.dart';
import 'package:garage_management/models/carModel.dart';
import '../models/addCustomerCar.dart';
import '../models/customerCar.dart';
import '../models/carModelYear.dart';
import '../models/customer.dart';
import 'package:http/http.dart' as http;
import 'carManufacturer.dart';

class CustomerCarsPage extends StatefulWidget {
  final Customer customer;
  final List<CustomerCar> customerCars;

  const CustomerCarsPage({Key? key, required this.customer, required this.customerCars}) : super(key: key);

  @override
  _CustomerCarsPageState createState() => _CustomerCarsPageState();
}

class _CustomerCarsPageState extends State<CustomerCarsPage> {
  late Future<List<CustomerCar>> customerCars;
  List<CarEnginetype> _engineTypes = [];
  CarEnginetype? _selectedEngineType;
  List<CarManufacturer> _carManufacturers = [];
  CarManufacturer? _selectedCarManufacturer;
  List<CarModel> _carModels = [];
  CarModel? _selectedCarModel;
  List<CarModelYear> _carModelYears = [];
  CarModelYear? _selectedCarModelYear;

  // Declare TextEditingControllers for the fields
  TextEditingController vinController = TextEditingController();
  TextEditingController licencePlateController = TextEditingController();
  TextEditingController kilometerController = TextEditingController();

  Future<List<CustomerCar>> fetchCustomerCars() async {
    await Future.delayed(Duration(seconds: 2));
    return widget.customerCars;
  }

  Future<void> _refreshCars() async {
    // Wait for the data to be fetched
    List<CustomerCar> fetchedCars = await fetchCustomerCars();

    // Update the state with the fetched customer cars
    setState(() {
      customerCars = fetchedCars as Future<List<CustomerCar>>;
    });
  }


  @override
  void initState() {
    super.initState();
    customerCars = fetchCustomerCars();
  }

  @override
  void dispose() {
    // Don't forget to dispose the controllers when done to prevent memory leaks
    vinController.dispose();
    licencePlateController.dispose();
    kilometerController.dispose();
    super.dispose();
  }

  void _showCarInfoPopup(BuildContext context, CustomerCar car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.carDetails),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoPopupItem(AppLocalizations.of(context)!.carManufacturer, car.manufacturerName),
                _buildInfoPopupItem(AppLocalizations.of(context)!.carModel, car.modelName),
                _buildInfoPopupItem(AppLocalizations.of(context)!.carModelYear, car.modelYear.toString()),
                _buildInfoPopupItem(AppLocalizations.of(context)!.carVinNumber, car.vin),
                _buildInfoPopupItem(AppLocalizations.of(context)!.licencePlate, car.licencePlate),
                _buildInfoPopupItem(AppLocalizations.of(context)!.kilometer, car.kilometer.toString()),
                _buildInfoPopupItem(AppLocalizations.of(context)!.fuelType, car.fuelType),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoPopupItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _addCustomerCar(BuildContext context) async {
    // Fetch car engine types before showing the dialog
    await fetchCarEngineTypes();
    await fetchCarManufacturers();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from closing when tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {  // Add StatefulBuilder
            return WillPopScope(  // Intercept back button press
              onWillPop: () async {
                // Reset variables when dialog is dismissed
                _carManufacturers = [];
                _selectedCarManufacturer = null;
                _carModels = [];
                _selectedCarModel = null;
                _carModelYears = [];
                _selectedCarModelYear = null;
                _engineTypes = [];
                _selectedEngineType = null;

                return true;  // Allow the dialog to close
              },
              child: AlertDialog(
                title: Text(AppLocalizations.of(context)!.addCustomerCar),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView( // Make the content scrollable
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCarManufacturerDropdown(setDialogState),
                        _buildCarModelDropdown(setDialogState),
                        _buildCarModelYearDropdown(setDialogState),
                        // VIN TextField
                        _buildAddPopupItem(AppLocalizations.of(context)!.carVinNumber, vinController),
                        // License Plate TextField
                        _buildAddPopupItem(AppLocalizations.of(context)!.licencePlate, licencePlateController),
                        // Kilometer TextField
                        _buildAddPopupItem(AppLocalizations.of(context)!.kilometer, kilometerController),
                        _buildEngineTypeDropdown(setDialogState),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Cancel button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Reset variables when cancel is clicked
                      _carManufacturers = [];
                      _selectedCarManufacturer = null;
                      _carModels = [];
                      _selectedCarModel = null;
                      _carModelYears = [];
                      _selectedCarModelYear = null;
                      _engineTypes = [];
                      _selectedEngineType = null;
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel, color: Colors.red), // Cancel icon
                        SizedBox(width: 5),
                        Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.red)), // Text
                      ],
                    ),
                  ),
                  // Add button
                  TextButton(
                    onPressed: () {
                      // Get the selected values from the dropdowns
                      int manufacturerId = _selectedCarManufacturer?.id ?? 0;  // Get the ID of the selected manufacturer
                      int modelId = _selectedCarModel?.id ?? 0;  // Get the ID of the selected model
                      int modelYearId = _selectedCarModelYear?.id ?? 0;  // Get the ID of the selected model year
                      String vin = vinController.text;  // Get VIN from the controller
                      String licencePlate = licencePlateController.text;  // Get Licence Plate from the controller
                      int kilometer = int.tryParse(kilometerController.text) ?? 0;  // Get Kilometer, default to 0 if empty
                      String color = ''; // You can get the Color value from the respective text field if needed

                      // Fix the fuelType to be an integer from _selectedEngineType (getting the id)
                      int fuelType = _selectedEngineType?.id ?? 0;  // Using the 'id' field from selected engine type

                      // Create the CustomerCar object
                      AddCustomerCar addCustomerCar = AddCustomerCar(
                        id: 0,  // Assuming ID is generated later or passed in if needed
                        customerID: 1,  // Set customerID as required
                        manufacturerName: manufacturerId.toString(),  // Use ID here for manufacturerName
                        modelName: modelId.toString(),  // Use ID here for modelName
                        modelYear: modelYearId,  // Use ID here for modelYear
                        vin: vin,
                        licencePlate: licencePlate,
                        kilometer: kilometer,
                        color: 1, // You can set the actual color value here if needed
                        fuelType: fuelType,  // Corrected fuelType assignment
                        carImage: '',
                        garageID: 1,
                      );

                      // Add the customer car
                      addCustomerCarRequest(addCustomerCar);

                      // Reset the variables
                      _carManufacturers = [];
                      _selectedCarManufacturer = null;
                      _carModels = [];
                      _selectedCarModel = null;
                      _carModelYears = [];
                      _selectedCarModelYear = null;
                      _engineTypes = [];
                      _selectedEngineType = null;

                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Ensures the row takes only the necessary space
                      children: [
                        Icon(Icons.save, color: Colors.green), // Save icon
                        SizedBox(width: 5), // Space between icon and text
                        Text(AppLocalizations.of(context)!.add, style: TextStyle(color: Colors.green)), // Text
                      ],
                    ),
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addCustomerCarRequest(AddCustomerCar customerCar) async {
    try {
      final Map<String, dynamic> requestBody = {
        if (customerCar.id != null) 'id': 0,
        if (customerCar.customerID != null) 'CustomerID': 1,
        if (customerCar.licencePlate != null) 'LicencePlate': customerCar.licencePlate,
        if (customerCar.vin != null) 'VIN': customerCar.vin,
        if (customerCar.color != null) 'Color': customerCar.color,
        if (customerCar.kilometer != null) 'Kilometer': customerCar.kilometer,
        if (customerCar.manufacturerName != null) 'ModelManufacturer': customerCar.manufacturerName,
        if (customerCar.modelName != null) 'Model': customerCar.modelName,
        if (customerCar.modelYear != null) 'ModelYear': customerCar.modelYear,
        if (customerCar.fuelType != null) 'FuelType': customerCar.fuelType,
        // if (customerCar.carImage != null) 'CarImage': null,
        // if (customer.customerHomePhone != null) 'CustomerHomePhone': customer.customerHomePhone,
        if (customerCar.garageID != null) 'GarageID': customerCar.garageID,

      };

      // Debugging: Print the request body to the console
      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse('https://garagewebapi.eu/api/AddCustomerCar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Customer Car Added");
        //_refreshEmployees();
        return;
      } else {
        throw Exception('Failed to add customer car with error code ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchCarManufacturers() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCarManufacturers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _carManufacturers = jsonList.map((jsonItem) => CarManufacturer.fromJson(jsonItem)).toList();
          // if (_carManufacturers.isNotEmpty) {
          //   _selectedCarManufacturer = _carManufacturers.first; // Select the first by default
          // }
        });
      } else {
        throw Exception('Failed to load car manufacturers');
      }
    } catch (e) {
      print("Error fetching car manufacturers: $e");
    }
  }

  Future<List<CarModel>> fetchCarModels(int manufacturerID) async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCarModelManufacturerYearByManufacturerID/$manufacturerID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Car Models Response: ${response.body}");
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((jsonItem) => CarModel.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load car models');
      }
    } catch (e) {
      print("Error fetching car models: $e");
      return []; // Return an empty list on error
    }
  }

  Future<List<CarModelYear>> fetchCarModelYears(int carModelID) async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCarModelManufacturerYearByModelID/$carModelID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Model Years: ${response.body}");
        List<dynamic> jsonList = json.decode(response.body);

        return jsonList.map((jsonItem) => CarModelYear.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load car model years');
      }
    } catch (e) {
      print("Error fetching car model years: $e");
      return [];
    }
  }

  Future<void> fetchCarEngineTypes() async {
    try {
      final response = await http.get(
        Uri.parse('https://garagewebapi.eu/api/GetCarEngineTypesToList'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _engineTypes = jsonList.map((jsonItem) => CarEnginetype.fromJson(jsonItem)).toList();
        });
      } else {
        throw Exception('Failed to load car engine types');
      }
    } catch (e) {
      print("Error fetching engine types: $e");
    }
  }

  Widget _buildAddPopupItem(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,  // Adjust the width as needed
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,  // The label will be inside the textfield as a hint
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Manufacturer Dropdown
  Widget _buildCarManufacturerDropdown(Function setDialogState) {
    return _buildDropdownRow(
      child: DropdownButton<CarManufacturer>(
        isExpanded: true,
        value: _selectedCarManufacturer ?? null, // Ensure it's null initially
        hint: Text(AppLocalizations.of(context)!.carManufacturer), // Updated hint text
        items: _carManufacturers.map((CarManufacturer manufacturer) {
          return DropdownMenuItem<CarManufacturer>(
            value: manufacturer,
            child: Text(manufacturer.manufacturerName),
          );
        }).toList(),
        onChanged: (CarManufacturer? newValue) {
          if (newValue != null) {
            setDialogState(() {
              _selectedCarManufacturer = newValue;
              _selectedCarModel = null;
              _carModels = [];
              _selectedCarModelYear = null;
              _carModelYears = [];
            });

            fetchCarModels(newValue.id).then((models) {
              setDialogState(() {
                _carModels = models;
              });
            });
          }
        },
      ),
    );
  }

// Car Model Dropdown
  Widget _buildCarModelDropdown(Function setDialogState) {
    return _buildDropdownRow(
      child: DropdownButton<CarModel>(
        isExpanded: true,
        value: _selectedCarModel,
        hint: Text(AppLocalizations.of(context)!.carModel),
        items: _carModels.isNotEmpty
            ? _carModels.map((CarModel model) {
          return DropdownMenuItem<CarModel>(
            value: model,
            child: Text(model.modelName),
          );
        }).toList()
            : [],
        onChanged: _carModels.isEmpty
            ? null
            : (CarModel? newValue) {
          setDialogState(() {
            _selectedCarModel = newValue;
            _selectedCarModelYear = null;
            _carModelYears = [];
          });

          fetchCarModelYears(_selectedCarModel!.id).then((carModelYears) {
            setDialogState(() {
              _carModelYears = carModelYears;
            });
          });
        },
      ),
    );
  }

// Car Model Year Dropdown
  Widget _buildCarModelYearDropdown(Function setDialogState) {
    return _buildDropdownRow(
      child: DropdownButton<CarModelYear>(
        isExpanded: true,
        value: _selectedCarModelYear,
        hint: Text(AppLocalizations.of(context)!.carModelYear),
        items: _carModelYears.isNotEmpty
            ? _carModelYears.map((CarModelYear model) {
          return DropdownMenuItem<CarModelYear>(
            value: model,
            child: Text(model.description),
          );
        }).toList()
            : [],
        onChanged: _carModelYears.isEmpty
            ? null
            : (CarModelYear? newValue) {
          setDialogState(() {
            _selectedCarModelYear = newValue;
          });
        },
      ),
    );
  }

// Engine Type Dropdown
  Widget _buildEngineTypeDropdown(Function setDialogState) {
    return _buildDropdownRow(
      child: DropdownButton<CarEnginetype>(
        isExpanded: true,
        value: _selectedEngineType,
        hint: Text(AppLocalizations.of(context)!.carFuelType),
        items: _engineTypes.map((CarEnginetype engine) {
          return DropdownMenuItem<CarEnginetype>(
            value: engine,
            child: Text(engine.fuelType),
          );
        }).toList(),
        onChanged: (CarEnginetype? newValue) {
          setDialogState(() {
            _selectedEngineType = newValue;
          });
        },
      ),
    );
  }

// Generic Dropdown Row Wrapper
  Widget _buildDropdownRow({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customerCarsList),
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(Icons.directions_car, size: 36), // Car icon
                Positioned(
                  right: 0,
                  top: -1,
                  child: Icon(Icons.add_circle, size: 16, color: Colors.green), // Small add icon
                ),
              ],
            ),
            onPressed: () {
              _addCustomerCar(context);
            },
          ),
        ],
      ),


      body: RefreshIndicator(
        onRefresh: _refreshCars,
        child: FutureBuilder<List<CustomerCar>>(
          future: customerCars,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No cars found for this customer."));
            } else {
              List<CustomerCar> customerCars = snapshot.data!;

              return ListView.builder(
                itemCount: customerCars.length,
                itemBuilder: (context, index) {
                  CustomerCar car = customerCars[index];

                  return Dismissible(
                    key: Key(car.vin),
                    background: _swipeRightBackground(),
                    secondaryBackground: _swipeLeftBackground(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        print("Service for ${car.manufacturerName} ${car.modelName}");
                      } else {
                        _showCarInfoPopup(context, car); // 🛠 FIX: Await the function so the UI updates correctly
                      }
                      if (!mounted) return false; // Prevent crash
                      setState(() {}); // Ensure UI rebuilds
                      return false; // Prevent removal
                    },
                    child: GestureDetector( // 🛠 FIX: Wrap with GestureDetector to enable tapping
                      onTap: () => _showCarInfoPopup(context, car),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                        child: ListTile(
                          title: Text(
                            "${car.manufacturerName} ${car.modelName} (${car.modelYear})",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${AppLocalizations.of(context)!.licencePlate}: ${car.licencePlate} - ${AppLocalizations.of(context)!.kilometer}: ${car.kilometer}",
                            style: TextStyle(fontSize: 14),
                          ),
                          leading: Icon(Icons.directions_car, color: Colors.blue, size: 30),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  /// Swipe Right Background (Service)
  Widget _swipeRightBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.white, size: 30),
          SizedBox(width: 10),
          //Text("Service", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Swipe Left Background (Info)
  Widget _swipeLeftBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //Text("Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.history, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}