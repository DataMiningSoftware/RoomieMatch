enum Personality { Introverted, Extroverted, Ambivert }

extension PersonalityExtension on Personality {
  int get value {
    switch (this) {
      case Personality.Introverted:
        return 0;
      case Personality.Ambivert:
        return 1;
      case Personality.Extroverted:
        return 2;
    }
  }
}

enum GuestsOver { Often, Sometimes, Never }

extension GuestsOverExtension on GuestsOver {
  int get value {
    switch (this) {
      case GuestsOver.Often:
        return 0;
      case GuestsOver.Sometimes:
        return 1;
      case GuestsOver.Never:
        return 2;
    }
  }
}

enum LoudNoise { Yes, No }

extension LoudNoiseExtension on LoudNoise {
  int get value {
    switch (this) {
      case LoudNoise.Yes:
        return 0;
      case LoudNoise.No:
        return 1;
    }
  }
}

enum Cleanliness { Verytidy, Moderate, Casual }

extension CleanlinessExtension on Cleanliness {
  int get value {
    switch (this) {
      case Cleanliness.Verytidy:
        return 0;
      case Cleanliness.Moderate:
        return 1;
      case Cleanliness.Casual:
        return 2;
    }
  }
}

enum Smoke { Yes, No }

extension SmokeExtension on Smoke {
  int get value {
    switch (this) {
      case Smoke.Yes:
        return 0;
      case Smoke.No:
        return 1;
    }
  }
}

enum GuestsFeeling { Often, Occasionally, Never }

extension GuestsFeelingExtension on GuestsFeeling {
  int get value {
    switch (this) {
      case GuestsFeeling.Often:
        return 0;
      case GuestsFeeling.Occasionally:
        return 1;
      case GuestsFeeling.Never:
        return 2;
    }
  }
}

enum Sociality { Social, Private, Balanced }

extension SocialityExtension on Sociality {
  int get value {
    switch (this) {
      case Sociality.Social:
        return 0;
      case Sociality.Balanced:
        return 1;
      case Sociality.Private:
        return 2;
    }
  }
}

enum LoudTv { Yes, No }

extension LoudTvExtension on LoudTv {
  int get value {
    switch (this) {
      case LoudTv.Yes:
        return 0;
      case LoudTv.No:
        return 1;
    }
  }
}

enum ContributeCleaning { Veryimportant, Somewhat, Notimportant }

extension ContributeCleaningExtension on ContributeCleaning {
  int get value {
    switch (this) {
      case ContributeCleaning.Notimportant:
        return 0;
      case ContributeCleaning.Somewhat:
        return 1;
      case ContributeCleaning.Veryimportant:
        return 2;
    }
  }
}

enum RoommateSmoke { Yes, No, Onlyoutside }

extension RoommateSmokeExtension on RoommateSmoke {
  int get value {
    switch (this) {
      case RoommateSmoke.Yes:
        return 0;
      case RoommateSmoke.No:
        return 1;
      case RoommateSmoke.Onlyoutside:
        return 2;
    }
  }
}