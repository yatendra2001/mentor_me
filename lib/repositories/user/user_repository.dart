import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_me/config/paths.dart';
import 'package:mentor_me/models/models.dart';
import 'package:mentor_me/repositories/user/base_user_repository.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'package:mentor_me/widgets/widgets.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<User> getUserWithId({required String userId}) async {
    final doc =
        await _firebaseFirestore.collection(Paths.users).doc(userId).get();
    return doc.exists ? User.fromDocument(doc) : User.empty;
  }

  @override
  Future<void> updateUser({required User user}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(user.id)
        .update(user.toDocument());
  }

  @override
  Future<void> setUser({required User user}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Future<List<User>> searchUsers({required String query}) async {
    List<User> list1, list2;

    final blockSnap = await _firebaseFirestore
        .collection(Paths.blockUser)
        .doc(SessionHelper.uid)
        .collection(Paths.userblockingIds)
        .get();

    List<String> blockedIds = blockSnap.docs.map((doc) => doc.id).toList();

    final userNameSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .get();
    list1 = userNameSnap.docs.map((doc) => User.fromDocument(doc)).toList();

    final nameSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('username', isGreaterThanOrEqualTo: query)
        .get();

    list2 = nameSnap.docs.map((doc) => User.fromDocument(doc)).toList();
    list1.removeWhere((user) => list2.contains(user));
    list1.addAll(list2);
    list1.removeWhere((user) => blockedIds.contains(user.id));
    return list1;
  }

  @override
  Future<bool> searchUserbyPhone(
      {required String query, required bool newAccount}) async {
    try {
      return await _firebaseFirestore
          .collection(Paths.users)
          .where("phoneNumber", isEqualTo: query)
          .snapshots()
          .isEmpty;
    } on FirebaseException catch (err) {
      if (err.code == 'permission-denied') {
        flutterToast(
            msg: newAccount ? 'New Account' : 'Account does not exists',
            position: ToastGravity.CENTER);
      } else {
        flutterToast(msg: 'An Error occured', position: ToastGravity.CENTER);
      }
    } catch (err) {
      flutterToast(msg: 'An Error occured', position: ToastGravity.CENTER);
    }
    return true;
  }

  @override
  Future<bool> searchUserbyUsername({required String query}) async {
    try {
      final QuerySnapshot users = await _firebaseFirestore
          .collection(Paths.users)
          .where(Paths.usernameLower, isEqualTo: query.toLowerCase())
          .get();
      return users.size == 0;
    } on FirebaseException catch (err) {
      log(err.message!);
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      var result =
          await _firebaseFirestore.collection(Paths.users).doc(username).get();
      return result.exists;
    } catch (e) {
      log(e.toString());
    }
    return true;
  }
}
