import 'package:flutter/material.dart';

/// Help modules available from the Help hub.
enum HelpTopic {
  bug,
  contact,
  feature,
}

extension HelpTopicX on HelpTopic {
  String get pathSegment => switch (this) {
        HelpTopic.bug => 'bug',
        HelpTopic.contact => 'contact',
        HelpTopic.feature => 'feature',
      };

  String get title => switch (this) {
        HelpTopic.bug => 'Raise a bug',
        HelpTopic.contact => 'Contact us',
        HelpTopic.feature => 'New feature request',
      };

  String get description => switch (this) {
        HelpTopic.bug =>
          'Report something broken in the product so engineering can investigate.',
        HelpTopic.contact =>
          'Reach the Saasify team for account questions, billing, or general support.',
        HelpTopic.feature =>
          'Suggest an improvement or capability that would help your team work faster.',
      };

  IconData get icon => switch (this) {
        HelpTopic.bug => Icons.bug_report_outlined,
        HelpTopic.contact => Icons.mail_outline,
        HelpTopic.feature => Icons.lightbulb_outline,
      };

  String get formHint => switch (this) {
        HelpTopic.bug =>
          'Describe the issue, steps to reproduce, and expected result…',
        HelpTopic.contact => 'How can we help you today?',
        HelpTopic.feature =>
          'Tell us the problem and the feature you would like to see…',
      };

  String get submitLabel => switch (this) {
        HelpTopic.bug => 'Submit bug',
        HelpTopic.contact => 'Send message',
        HelpTopic.feature => 'Submit request',
      };

  static HelpTopic? tryParse(String segment) {
    for (final topic in HelpTopic.values) {
      if (topic.pathSegment == segment) return topic;
    }
    return null;
  }
}
