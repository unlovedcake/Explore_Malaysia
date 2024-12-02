import 'package:dio/dio.dart';
import 'package:explore_malaysia/data/mock_data.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';
import 'package:explore_malaysia/models/property.dart';
import 'package:explore_malaysia/models/statistics.dart';
import 'package:explore_malaysia/store/app_state.dart';

const String baseUrl = 'https://api.exploremalaysia.com';

// Actions
class SetLoadingAction {
  final bool isLoading;
  SetLoadingAction(this.isLoading);
}

class SetErrorAction {
  final String error;
  SetErrorAction(this.error);
}

class SetPropertiesAction {
  final List<Property> properties;

  SetPropertiesAction(this.properties);
}

class SetFilteredPropertiesAction {
  final List<Property> filteredProperties;
  SetFilteredPropertiesAction(this.filteredProperties);
}

class SetFiltersAction {
  final Map<String, dynamic> filters;
  SetFiltersAction(this.filters);
}

class SetStatisticsAction {
  final PropertyStatistics statistics;
  SetStatisticsAction(this.statistics);
}

class FetchPropertiesAction {}

void propertyMiddleware(Store<AppState> store, dynamic action, NextDispatcher next) async {
  final dio = Dio();
  if (action is FetchPropertiesAction) {
    try {
      store.dispatch(SetLoadingAction(true));
      final response = await dio.get("http://apishopdev.mooo.com/api/property.php");
      if (response.statusCode == 200) {
        print('HOYS $response');
        final List<Property> properties =
            (response.data as List<dynamic>).map((json) => Property.fromJson(json)).toList();
        store.dispatch(SetPropertiesAction(properties));
        store.dispatch(SetFilteredPropertiesAction(properties));
        store.dispatch(SetLoadingAction(false));
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      store.dispatch(SetErrorAction('Error : $error'));
      print("Error fetching properties: $error");
    }
  }
  next(action);
}

// Thunk action to fetch properties
dynamic fetchPropertiesThunk() {
  return (dynamic dispatch, dynamic getState) async {
    dispatch(SetLoadingAction(true));

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Convert mock data to Property objects
      final properties = mockProperties.map((json) => Property.fromJson(json)).toList();

      dispatch(SetPropertiesAction(properties));
      dispatch(SetFilteredPropertiesAction(properties));
      dispatch(SetLoadingAction(false));
    } catch (e) {
      dispatch(SetErrorAction(e.toString()));
      dispatch(SetLoadingAction(false));
    }
  };
}

// Thunk action to filter properties
dynamic filterPropertiesThunk(Map<String, dynamic> filters) {
  return (dynamic dispatch, dynamic getState) {
    final state = getState();
    final List<Property> allProperties = state.properties;

    List<Property> filtered = allProperties.where((property) {
      bool matches = true;

      if (filters['minPrice'] != null) {
        matches &= property.price >= filters['minPrice'];
      }
      if (filters['maxPrice'] != null) {
        matches &= property.price <= filters['maxPrice'];
      }
      if (filters['location'] != null) {
        matches &= property.location.toLowerCase().contains(
              filters['location'].toLowerCase(),
            );
      }
      if (filters['propertyType'] != null) {
        matches &= property.propertyType == filters['propertyType'];
      }
      if (filters['bedrooms'] != null) {
        matches &= property.bedrooms >= filters['bedrooms'];
      }

      return matches;
    }).toList();

    dispatch(SetFilteredPropertiesAction(filtered));
    dispatch(SetFiltersAction(filters));
  };
}

// Action Creators
ThunkAction<AppState> fetchStatistics() {
  return (Store<AppState> store) async {
    store.dispatch(SetLoadingAction(true));

    try {
      // For development, using mock data
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'total_properties': 1250,
        'total_apartments': 750,
        'total_houses': 500,
        'average_price': 450000.0,
      };

      final statistics = PropertyStatistics.fromJson(mockResponse);
      store.dispatch(SetStatisticsAction(statistics));
    } catch (e) {
      store.dispatch(SetErrorAction(e.toString()));
    } finally {
      store.dispatch(SetLoadingAction(false));
    }
  };
}
