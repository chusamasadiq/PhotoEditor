import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/module/edit_photo/presentation/cubit/edit_photo_cubit.dart';

class EditPhotoWidget extends StatelessWidget {
  const EditPhotoWidget({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final ImageProvider photo;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        OriginalImage(photo: photo),
        const ComponentLayer(),
      ],
    );
  }
}

class OriginalImage extends StatelessWidget {
  const OriginalImage({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final ImageProvider photo;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: photo,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image_sharp,
            color: Colors.blueGrey,
          ),
        );
      },
    );
  }
}

class ComponentLayer extends StatelessWidget {
  const ComponentLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPhotoCubit, EditPhotoState>(
      buildWhen: (previous, current) {
        return previous.opacityLayer != current.opacityLayer ||
            previous.widgets != current.widgets;
      },
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Opacity layer
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(state.opacityLayer),
              ),
            ),

            // Widgets
            for (var i = 0; i < state.widgets.length; i++)
              Align(
                key: UniqueKey(),
                alignment: Alignment.center,
                child: state.widgets[i],
              ),
          ],
        );
      },
    );
  }
}
