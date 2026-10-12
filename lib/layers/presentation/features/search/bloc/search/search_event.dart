part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchLocalEvent extends SearchEvent {
  final String query;
  final int offset;

  const SearchLocalEvent(this.query, {this.offset = 0});

  @override
  List<Object> get props => [query, offset];
}

class SearchExternalEvent extends SearchEvent {
  final String query;
  final int offset;

  const SearchExternalEvent(this.query, {this.offset = 0});

  @override
  List<Object> get props => [query, offset];
}

class ClearSearchEvent extends SearchEvent {}
