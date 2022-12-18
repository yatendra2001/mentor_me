import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentor_me/models/event_model.dart';
import 'package:mentor_me/models/failure_model.dart';
import 'package:mentor_me/repositories/event/event_repository.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'package:mentor_me/widgets/widgets.dart';
part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _eventRepository;

  EventBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(EventState.initial());

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  Stream<EventState> mapEventToState(event) async* {
    if (event is GetUserEvent) {
      yield* _mapToGetUserEvent(event);
    } else if (event is JoinEvent) {
      yield* _mapToJoinEvent(event);
    }
  }

  Stream<EventState> _mapToGetUserEvent(GetUserEvent event) async* {
    if (state.status != EventStatus.loading) {
      yield state.copyWith(status: EventStatus.loading);
      List<Event> events =
          await _eventRepository.getUserEvents(userId: SessionHelper.uid!);
      yield state.copyWith(events: events, status: EventStatus.loaded);
    }
  }

  Stream<EventState> _mapToJoinEvent(JoinEvent event) async* {}

  Future<bool> directToPayment({required String joinCode}) async {
    final communityEvent = await _eventRepository.joinEvent(
        roomCode: joinCode, userId: SessionHelper.uid!);
    flutterToast(msg: "Added");
    add(const GetUserEvent());
    if (communityEvent != null) {
      if (communityEvent.paid == true) {
        return true;
      } else {
        return false;
      }
    }
    flutterToast(msg: "Unable to verify the code. Check the code again.");
    return false;
  }
}
