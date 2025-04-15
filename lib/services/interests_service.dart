import 'package:hive/hive.dart';

class InterestsService {
  
  //Create Interest
  static Future createInterest(interest) async {
    Box interestBox = Hive.box('interestsBox');
    var oldInterests = await interestBox.get("interests") ?? [];
    var newInterests = [...oldInterests, interest];
    await interestBox.put("interests", newInterests);
    await interestBox.close();
  }

  //Get All Interests
  static Future<List> getSessions() async  {
    Box interestBox = Hive.box('interestsBox');
    var interests = await interestBox.get("interests") ?? [];
    await interestBox.close();
    return interests;
  }

  // Delete one interest
  static Future deleteOneInterest(interest) async {
    Box interestBox = Hive.box('interestsBox');
    var interests = await interestBox.get("interests") ?? [];
    try {
        interests.remove(interest);
    } catch (e) {}
    await interestBox.close();
    await interestBox.put("interests", interests);
    await interestBox.close();
  }

  // Delete All interest 
  static Future deleteInterests() async {
    Box interestBox = Hive.box('interestsBox');
    await interestBox.put("interests", []);
    await interestBox.close();
  }

}