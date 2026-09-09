import 'package:intl/intl.dart';

import '../helpers/auth_box_helper.dart';
import 'message_db_service.dart';

class MockBackend {
  MockBackend._();

  static const List<Map<String, dynamic>> _mockMatches = [
    {
      "user_id": "m1",
      "image": "assets/profile/1.jpg",
      "first_name": "Emma",
      "age": 22,
      "gender": "F",
      "distance": 3,
      "budget": 850,
      "match_score": 92,
      "job": "Graphic Designer",
      "location": "Semenyih, Selangor",
      "bio": "Coffee lover, amateur photographer and a big fan of weekend hikes. Looking for a clean, friendly housemate.",
      "interests": ["Hiking", "Coffee", "Photography"],
    },
    {
      "user_id": "m2",
      "image": "assets/profile/2.jpg",
      "first_name": "Bruno",
      "age": 24,
      "gender": "M",
      "distance": 5,
      "budget": 700,
      "match_score": 88,
      "job": "Software Engineer",
      "location": "Kajang, Selangor",
      "bio": "Night owl who codes by day and games by night. Pretty tidy, mostly quiet, always up for badminton.",
      "interests": ["Gaming", "Badminton", "Coding"],
    },
    {
      "user_id": "m3",
      "image": "assets/profile/3.png",
      "first_name": "Jasnie",
      "age": 21,
      "gender": "F",
      "distance": 8,
      "budget": 900,
      "match_score": 84,
      "job": "Psychology Student",
      "location": "Bangi, Selangor",
      "bio": "Plant mom and bookworm. I bake on weekends and love a calm, cozy home environment.",
      "interests": ["Reading", "Baking", "Plants"],
    },
    {
      "user_id": "m4",
      "image": "assets/profile/7.jpg",
      "first_name": "Zack",
      "age": 25,
      "gender": "M",
      "distance": 12,
      "budget": 650,
      "match_score": 79,
      "job": "Freelance Videographer",
      "location": "Cheras, Kuala Lumpur",
      "bio": "Always out shooting or editing. Easygoing, sociable, and happy to share film recommendations.",
      "interests": ["Film", "Travel", "Music"],
    },
    {
      "user_id": "m5",
      "image": "assets/profile/5.png",
      "first_name": "Mimi",
      "age": 23,
      "gender": "F",
      "distance": 15,
      "budget": 780,
      "match_score": 75,
      "job": "Marketing Executive",
      "location": "Puchong, Selangor",
      "bio": "Fitness enthusiast and foodie. Early riser, loves a tidy kitchen and movie nights.",
      "interests": ["Fitness", "Food", "Movies"],
    },
    {
      "user_id": "m6",
      "image": "assets/profile/8.png",
      "first_name": "Daniel",
      "age": 26,
      "gender": "M",
      "distance": 20,
      "budget": 950,
      "match_score": 71,
      "job": "Architect",
      "location": "Mont Kiara, Kuala Lumpur",
      "bio": "Design-obsessed and organised. Prefer a quiet flat with good light and great coffee nearby.",
      "interests": ["Architecture", "Coffee", "Minimalism"],
    },
    {
      "user_id": "m7",
      "image": "assets/profile/6.png",
      "first_name": "Sofia",
      "age": 22,
      "gender": "F",
      "distance": 25,
      "budget": 600,
      "match_score": 68,
      "job": "Nursing Student",
      "location": "Serdang, Selangor",
      "bio": "Cheerful and responsible. Shift worker so I value a quiet home and considerate flatmates.",
      "interests": ["Volunteering", "Yoga", "Cooking"],
    },
    {
      "user_id": "m8",
      "image": "assets/profile/10.png",
      "first_name": "Ken",
      "age": 24,
      "gender": "M",
      "distance": 30,
      "budget": 820,
      "match_score": 64,
      "job": "Accountant",
      "location": "Subang Jaya, Selangor",
      "bio": "Laid-back and reliable. Weekend cyclist, weekday homebody, always pays rent on time.",
      "interests": ["Cycling", "Finance", "Cooking"],
    },
  ];

  /// Public read-only view of the demo profiles.
  static List<Map<String, dynamic>> get profiles => List.unmodifiable(_mockMatches);

  /// Resolves the profile image path for a given user id.
  static String profileImageFor(String userId) {
    for (final m in _mockMatches) {
      if (m['user_id'] == userId) return m['image'] as String;
    }
    return 'assets/profile/1.jpg';
  }

  static Map<String, dynamic> get(String endpoint) {
    if (endpoint.contains('frontend-connection-check')) {
      return {"status": "OK"};
    }

    if (endpoint.contains('get-all-settings')) {
      return {
        "status": "OK",
        "notifPauseAll": "F",
        "notifMessages": "F",
        "notifNewMatch": "F",
        "sleepMode": "F",
        "sleepStartTime": "2200",
        "sleepEndTime": "0700",
        "sleepChooseDays": ["F", "F", "F", "F", "F", "F", "F"],
        "accountPrivacy": "F",
      };
    }

    if (endpoint.contains('get-all-profile')) {
      return {
        "status": "OK",
        "firstName": "Alex",
        "lastName": "Lee",
        "age": 22,
        "birthday": "2002-05-14",
        "gender": "M",
        "latitude": "2.9450",
        "longitude": "101.8740",
        "distance": 10,
        "budget": 800,
        "description": "Friendly student looking for a roommate.",
        "schoolJob": "University of Nottingham",
        "allergies": "None",
      };
    }

    if (endpoint.contains('get-all-matches')) {
      return {"status": "OK", "matches": _mockMatches};
    }

    if (endpoint.contains('get-stat')) {
      return {"status": "ERROR", "message": "No record found!"};
    }

    if (endpoint.contains('get-all-chats')) {
      final currUserId = AuthBoxHelper.getUserId();
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return {
        "status": "OK",
        "matched": [
          {"userId": currUserId, "chatUserId": "m1", "firstName": "Emma", "latestTime": nowSec - 3600},
          {"userId": currUserId, "chatUserId": "m2", "firstName": "Bruno", "latestTime": nowSec - 7200},
          {"userId": currUserId, "chatUserId": "m3", "firstName": "Jasnie", "latestTime": nowSec - 86400},
          {"userId": currUserId, "chatUserId": "m5", "firstName": "Mimi", "latestTime": nowSec - 172800},
        ],
      };
    }

    if (endpoint.contains('get-messages')) {
      return {"status": "OK", "messages": []};
    }

    if (endpoint.contains('get-messaging-public-key')) {
      return {"status": "OK", "publicKey": "", "keyId": 0};
    }

    return {"status": "OK"};
  }

  static Map<String, dynamic> post(String endpoint, Map<String, dynamic> data) {
    return {"status": "OK"};
  }

  /// Seeds the local messages database with demo conversations.
  static Future<void> seedMessages() async {
    final currUserId = AuthBoxHelper.getUserId();

    final Map<String, List<List<String>>> conversations = {
      "m1": [
        [currUserId, "Hey Emma! I saw we got matched 🎉"],
        ["m1", "Heyy! Yes, great to meet you 😊"],
        [currUserId, "Your profile says you love hiking. Any favourite trails around here?"],
        ["m1", "Broga Hill is my go-to for a quick weekend hike!"],
        [currUserId, "I've been meaning to go there. Mind if I join sometime?"],
        ["m1", "Of course! Let's plan it soon 🥾"],
      ],
      "m2": [
        ["m2", "Yo! You play badminton too?"],
        [currUserId, "Yeah! Been looking for a regular partner."],
        ["m2", "Perfect. There's a court near Kajang, we should book a slot."],
      ],
      "m3": [
        ["m3", "Hi! Love your profile. What books are you into?"],
        [currUserId, "Mostly fiction and a bit of self-improvement. You?"],
        ["m3", "Fantasy and thrillers mostly! I can recommend a few 📚"],
      ],
      "m5": [
        [currUserId, "Mimi, your cooking posts look amazing!"],
        ["m5", "Thank you! I love trying new recipes. What's your comfort food?"],
      ],
    };

    final base = DateTime(2026, 9, 9, 9, 0, 0);
    int offset = 0;

    for (final entry in conversations.entries) {
      final chatUserId = entry.key;
      for (final msg in entry.value) {
        final sender = msg[0];
        final text = msg[1];
        final senderId = sender == currUserId ? currUserId : chatUserId;
        final recipientId = sender == currUserId ? chatUserId : currUserId;
        final dt = base.add(Duration(minutes: offset++));
        await MessageDBService().insertMessage(
          senderId,
          recipientId,
          text,
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(dt),
        );
      }
    }
  }
}
