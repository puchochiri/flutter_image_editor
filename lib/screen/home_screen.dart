import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_editor/component/main_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_editor/component/footer.dart';
import 'package:flutter_image_editor/model/sticker_model.dart';
import 'package:flutter_image_editor/component/emoticon_sticker.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);



  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image; //선택한 이미지를 저장할 변수
  Set<StickerModel> stickers = {}; // 화면에 추가된 스티커를 저장할 변수
  String? selectedId; // 현재 선택된 스티커의 ID
  GlobalKey imgKey = GlobalKey();// 이미지로 전환할 위젯에 입력해줄 키값



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(  // 스크린에 Body, AppBar, Footer 순서로ㅅ 쌓을 준비
        fit: StackFit.expand,
        children: [
          renderBody(),
          // MainAppBar를 좌, 우, 위 끝이 정렬
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MainAppBar(
              onPickImage: onPickImage,
              onSaveImage: onSaveImage,
              onDeleteItem: onDeleteItem,
            ),
          ),
          //image가 선택되면 Footer 위치하기
          if(image != null)
            Positioned( // 맨 아래에 Footer 위젯 위치하기
              bottom: 0,
              // left와 right를 모두 0을 주면 좌우로 최대 크기를 차지함
              left: 0,
              right: 0,
              child: Footer(
                onEmoticonTap: onEmoticonTap,
              ),

            )
        ],

      )
    );

  }

  // build() 함수 아래에 작성
  Widget renderBody() {
    if(image != null) {
      //Stack 크기의 최대 크기만큼 차지하기
      return RepaintBoundary(
        //위젯을 이미지로 저장하는 데 사용
        key: imgKey,
        child: Positioned.fill(
          // 위젯 확대 및 좌우 이동을 가능하게 하는 위젯
          child:  InteractiveViewer(
            child: Stack(
              fit: StackFit.expand, // 크기 최대로 늘려주기
              children: [
                Image.file(
                  File(image!.path),
                  fit: BoxFit.cover, // 이미지 최대한 공간 차지하게 하기
                ),
                ...stickers.map(
                      (sticker) => Center( // 최초 스티커 선택 시 중앙에 배치
                    child: EmoticonSticker(
                      key: ObjectKey(sticker.id),
                      onTransform: () {
                        onTransform(sticker.id);
                      },
                      imgPath: sticker.imgPath,
                      isSelected: selectedId == sticker.id,
                    ),

                  ),
                ),
              ],
            ),

          ),
        ),
      );
    } else {
      // 이미지 선택이 안 된 경우 이미지 선택 버튼 표시
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: onPickImage,
          child: Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onTransform(String id) {
    // 스티커가 변형될 때 마다 변형 중인
    // 스티커를 현재 선택한 스티커로 지정
    setState(() {
      selectedId = id;
    });

  }

  void onEmoticonTap(int index) async {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(
          id: Uuid().v4(), // 스티커의 고유 ID
          imgPath: 'asset/img/emoticon_$index.png',
        )
      };
    });
  }

  // 미리 생성해둔 onPickImage() 함수 변경하기
  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    //갤러리에서 이미지 선택하기
    setState(() {
      this.image = image; // 선택한 이미지 저장하기
    });
  }

  // 미리 생성해둔 함수
  void onSaveImage() async {  // 이미지 저장 기능을 구현할 함수
    RenderRepaintBoundary boundary = imgKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    //바운더리를 이미지로 변경
    ui.Image image = await boundary.toImage(); //  바운더리를 이미지로 변경
    //byte data 형태로 현태 변경
    ByteData? byteData = await image.toByteData(format:  ui.ImageByteFormat.png);
    // Unit8List 행태로 변경
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // 이미지 저장하기
    await ImageGallerySaver.saveImage(pngBytes, quality: 100);
    ScaffoldMessenger.of(context).showSnackBar( //저장 후 Snackbar 보여주기
        SnackBar(
            content: Text('저장되었습니다.!'),
        ),

    );





  }

  void onDeleteItem() {
    setState(() {
      stickers = stickers.where((sticker) => sticker.id != selectedId).toSet();
      //현재 선택돼 있는 스티커 삭제 후 set로 변환
    });

  }


}