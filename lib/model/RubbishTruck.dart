import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
class RubbishTruck {
  String? team;
  String? round;
  int? startHour;
  int? startMinute;
  int? endHour;
  int? endMinute;
  String? name;
  double? latitude;
  double? longitude;

  RubbishTruck({
     this.team,
     this.round,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
     this.name,
     this.latitude,
     this.longitude,
  });

  @override
  String toString() {
    return 'RubbishTruck{team: $team, round: $round, startHour: $startHour, startMinute: $startMinute, endHour: $endHour, endMinute: $endMinute, name: $name, latitude: $latitude, longitude: $longitude}';
  }

  factory RubbishTruck.fromJson(Map<String, dynamic> json) {
    return RubbishTruck(
      team: json['team'] ?? '',
      round: json['round'] ?? '',
      startHour: json['startHour'] ?? 0,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 0,
      endMinute: json['endMinute'] ?? 0,
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class RubbishTrucksEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class FetchRubbishTrucks extends RubbishTrucksEvent{
  final int max;

  FetchRubbishTrucks(this.max);
  @override
  List<Object> get props => [max];
}

class RubbishTrucksState extends Equatable {
  @override
  List<Object> get props => [];
}
class RubbishTrucksAreLoaded extends RubbishTrucksState{
  final List<RubbishTruck> rubbishTrucks;
  RubbishTrucksAreLoaded(this.rubbishTrucks);
  @override
  List<Object> get props => [rubbishTrucks];
}
class RubbishTrucksFailed extends RubbishTrucksState{
  final String errorMessage;
  RubbishTrucksFailed(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}
class RubbishTrucksAreLoading extends RubbishTrucksState {}
class RubbishTrucksBloc extends Bloc<RubbishTrucksEvent,RubbishTrucksState>{
  RubbishTruckRepo rubbishTruckRepo = RubbishTruckRepo();
  RubbishTrucksBloc() : super(RubbishTrucksAreLoading()){
    on<FetchRubbishTrucks>(_itemsFetch);
  }
  void _itemsFetch(FetchRubbishTrucks event, Emitter<RubbishTrucksState> emit) async {
    emit(RubbishTrucksAreLoading());
    print('JP Flutter : try to fetch items');
    try {
      var items = await rubbishTruckRepo.getRubbishTrucks();
      print('JP Flutter :show all the items $items');
      emit(RubbishTrucksAreLoaded(items));
    } catch (exception) {
      emit(RubbishTrucksFailed(exception.toString()));
      emit(RubbishTrucksAreLoading());
    }
  }
}

class RubbishTruckRepo{
  Future<List<RubbishTruck>> getRubbishTrucks() async {
    http.Response response;
    print('JP Flutter : getRubbishTrucks 1');
    Uri url = Uri.parse('http://192.168.2.23:8080/taipei.pain.server/rest/rubbishtruck');

    print('JP Flutter : getRubbishTrucks 2');
    try {
      response = await http.get(url);
      print('JP Flutter : getRubbishTrucks wait back : ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        List<RubbishTruck> rubbishTrucks = responseData
            .map((truck) => RubbishTruck.fromJson(truck))
            .toList();
        return rubbishTrucks;
      } else {
        throw Exception('Failed to load rubbish trucks');
      }
    } catch (error) {
      throw error;
    }
  }

}