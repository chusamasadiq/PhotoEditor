import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_editor/module/edit_photo/model/dragable_widget_child.dart';
import 'package:photo_editor/module/edit_photo/presentation/widget/dragable_widget.dart';

part 'edit_photo_cubit.freezed.dart';
part 'edit_photo_state.dart';

class EditPhotoCubit extends Cubit<EditPhotoState> {
  EditPhotoCubit() : super(const EditPhotoState());

  void changeEditState(EditState editState) {
    emit(state.copyWith(editState: editState));
  }

  void changeOpacityLayer(double value) {
    emit(state.copyWith(opacityLayer: value));
  }

  void addWidget(DraggableWidget widget) {
    emit(state.copyWith(
      editState: EditState.idle,
      widgets: List.from(state.widgets)..add(widget),
    ));
  }

  void editWidget(int widgetId, DragableWidgetChild widget) {
    var index = state.widgets.indexWhere((e) => e.widgetId == widgetId);
    if (index == -1) return;

    state.widgets[index].child = widget;

    emit(state.copyWith(
      editState: EditState.idle,
      widgets: List.from(state.widgets),
    ));
  }

  void deleteWidget(int widgetId) {
    emit(state.copyWith(
      widgets: List.of(state.widgets)
        ..removeWhere((e) => e.widgetId == widgetId),
    ));
  }
}
