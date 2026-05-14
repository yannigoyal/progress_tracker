class AppStrings {
  const AppStrings._();

  static const appName = 'DailyLog';
  static const appVersionSubtitle = 'v1.0.0 · Offline first · No cloud';

  static const saveLog = 'Save log';
  static const saveSession = 'Save Session';
  static const close = 'Close';
  static const cancel = 'Cancel';
  static const create = 'Create';
  static const delete = 'Delete';
  static const deleteAll = 'Delete all';
  static const requiredField = 'Required';
  static const logDate = 'Date';

  static const todayScreenAddLogTooltip = 'Add log';
  static const todayScreenEmptyEmoji = '🌱';
  static const todayScreenEmptyTitle = 'Nothing logged yet today';
  static const todayScreenEmptySubtitle = 'Tap + to add your first entry';
  static const todayScreenLoadingDay = 'Day —';
  static String todayScreenDay(int dayNumber) => 'Day $dayNumber';
  static String genericScreenError(Object error) =>
      'Something went wrong\n$error';

  static const addLogSheetTitle = 'What did you work on?';

  static const deleteLogTitle = 'Delete log?';
  static String deleteLogMessage(String title) => 'Remove "$title"?';

  static const projectScreenTitle = 'Projects';
  static const projectDialogTitle = 'New Project';
  static const projectName = 'Project Name *';
  static const description = 'Description';
  static const sessionLogged = 'Session logged';
  static const projectEmptyEmoji = '📁';
  static const projectEmptyTitle = 'No projects yet';
  static const projectEmptySubtitle = 'Track your work in progress';
  static const newProject = 'New Project';
  static const today = 'today';
  static const yesterday = 'yesterday';
  static String daysAgo(int days) => '$days days ago';
  static String createdOn(String dateText) => 'Created $dateText';
  static String logSessionTitle(String projectName) =>
      'Log Session: $projectName';

  static const projectFormTitle = 'Project';
  static const whatDidYouDo = 'What did you do?';
  static const describeYourProgress = 'Describe your progress...';
  static const whatDidYouLearn = 'What did you learn?';
  static const keyTakeaways = 'Key takeaways...';

  static const readingFormTitle = 'Reading';
  static const bookNameRequired = 'Book Name *';
  static const pagesReadRequired = 'Pages Read *';
  static const keyTakeawayOrQuoteOptional = 'Key takeaway or quote (optional)';

  static const workoutFormTitle = 'Workout';
  static const exercise = 'Exercise';
  static const exerciseNameRequired = 'Exercise name *';
  static const durationSecondsRequired = 'Duration (seconds) *';
  static const countOrRepsRequired = 'Count / Reps *';
  static const sets = 'Sets';
  static const workoutPushups = 'Pushups';
  static const workoutPlank = 'Plank';
  static const workoutSquats = 'Squats';
  static const workoutPullUps = 'Pull-ups';
  static const workoutDips = 'Dips';
  static const workoutLunges = 'Lunges';
  static const workoutBurpees = 'Burpees';
  static const workoutSitUps = 'Sit-ups';
  static const workoutMountainClimbers = 'Mountain Climbers';
  static const workoutWallSit = 'Wall Sit';
  static const otherEllipsis = 'Other…';
  static const workoutExercises = [
    workoutPushups,
    workoutPlank,
    workoutSquats,
    workoutPullUps,
    workoutDips,
    workoutLunges,
    workoutBurpees,
    workoutSitUps,
    workoutMountainClimbers,
    otherEllipsis,
  ];

  static const dsaFormTitle = 'DSA / Coding';
  static const contentLabel = 'Content';
  static const miscLabel = 'Misc';
  static const leetCodeOptional = 'LeetCode # (optional)';
  static const problemNameRequired = 'Problem Name *';
  static const topic = 'Topic';
  static const approach = 'Approach';
  static const status = 'Status';
  static const solved = 'Solved';
  static const revised = 'Revised';
  static const solvedStatusLabel = '✅ Solved';
  static const revisedStatusLabel = '🔄 Revised';
  static const trackerSolvedSubtitle = 'Counts as solved in the tracker';
  static const trackerRevisionSubtitle = 'Keeps it marked as revision only';
  static const trackerMarked = 'Tracker Marked';
  static const dsaTopicDp = 'DP';
  static const dsaTopics = [
    'Array',
    'Two Pointers',
    'Sliding Window',
    'Stack',
    'Binary Search',
    'Linked List',
    'Trees',
    'Heap',
    dsaTopicDp,
    'Graph',
    'Backtracking',
    'Greedy',
    'Intervals',
    'Math',
    'Bit Manipulation',
    'HashMap',
    'Trie',
  ];
  static const dsaApproachMemoization = 'Memoization';
  static const dsaApproaches = [
    'Brute Force',
    'Two Pointers',
    'BFS/DFS',
    dsaApproachMemoization,
    'Tabulation',
    'Space-Opt',
    'Binary Search',
    'Greedy',
    'Divide & Conquer',
  ];

  static const contentFormTitle = 'Content Creation';
  static const platform = 'Platform';
  static const titleOrTopicRequired = 'Title / Topic *';
  static const progress = 'Progress';
  static const contentPlatformYoutube = 'YouTube';
  static const contentPlatformShorts = 'Shorts';
  static const contentPlatformInstagram = 'Instagram';
  static const contentPlatformLinkedIn = 'LinkedIn';
  static const contentPlatformOther = 'Other';
  static const contentPlatforms = [
    contentPlatformYoutube,
    contentPlatformShorts,
    // contentPlatformInstagram,
    // contentPlatformLinkedIn,
    contentPlatformOther,
  ];
  static const contentStatusRecorded = 'Recorded';
  static const contentStatusEdited = 'Edited';
  static const contentStatusUploaded = 'Uploaded';
  static const contentStatusMadeWithPyProgram = 'Made with py program';
  static const contentStatuses = [
    contentStatusRecorded,
    contentStatusEdited,
    contentStatusUploaded,
    contentStatusMadeWithPyProgram,
  ];

  static const learningFormTitle = 'Learning';
  static const whatDidYouLearnRequired = 'What did you learn? *';
  static const tags = 'Tags';
  static const learningTags = [
    'Flutter',
    'Dart',
    'DSA',
    'AI',
    'Web3',
    'Backend',
    'System Design',
    'DevOps',
    'iOS',
    'Android',
    'Web',
    'Math',
  ];

  static const miscFormTitle = 'Quick Note';
  static const titleOptional = 'Title (optional)';
  static const whatsOnYourMindRequired = 'What\'s on your mind? *';

  static const historyScreenTitle = 'Journal';
  static const searchLogs = 'Search logs…';
  static const all = 'All';
  static const historyToday = 'Today';
  static const historyEmptyEmoji = '📋';
  static const historyEmptyTitle = 'No entries found';
  static const historyEmptySubtitle = 'Start logging to see your history here';
  static const historyViewDetails = 'View';
  static const historyDetailTitle = 'Day details';
  static const historyDetailEmpty = 'No entries for this day';
  static String historyDsaSummary(int count) => '$count DSA';
  static String historyVideoSummary(int count) =>
      '$count video${count > 1 ? 's' : ''}';
  static String historyWorkoutSummary(int count) =>
      '$count workout${count > 1 ? 's' : ''}';
  static String historyRepsSummary(int reps) => '$reps reps';
  static String historyPagesSummary(int pages) => '$pages pages';
  static String historyNotesSummary(int count) =>
      '$count note${count > 1 ? 's' : ''}';
  static String historyProjectSummary(int count) =>
      '$count project update${count > 1 ? 's' : ''}';
  static const historyNoTrackedWork = 'No tracked work';
  static const noPrefix = 'no ';
  static const activityLoggedSuffix = ' activity logged.';

  static const dsaTrackerScreenTitle = 'Blind 75';
  static const dsaSolvedLowercase = 'solved';
  static const attempts = 'Attempts';
  static String attemptsWithCount(int count) => '$attempts ($count)';
  static String removedProgressMessage(String problemName) =>
      'Removed progress for $problemName';
  static String markedSolvedMessage(String problemName) =>
      'Marked $problemName as solved';

  static const statsScreenTitle = 'Stats';
  static const currentStreak = 'Current Streak';
  static const longestStreak = 'Longest Streak';
  static const last7Days = 'Last 7 days';
  static const last30Days = 'Last 30 days';
  static const totals = 'Totals';
  static String dayCount(int value) => '$value day${value == 1 ? '' : 's'}';
  static const unitProblemsSolved = 'problems solved';
  static const unitVideosUploaded = 'videos uploaded';
  static const unitTotalRepsOrSeconds = 'total reps / seconds';
  static const unitPagesRead = 'pages read';
  static const unitNotes = 'notes';
  static const unitSessionsLogged = 'sessions logged';

  static const contributionHeatmapTitle = 'Last year';
  static String heatmapMomentumText(int count) => count > 0
      ? '$count win${count == 1 ? '' : 's'} stacked'
      : 'Start with one win';
  static String heatmapSelectedDay(String dateLabel, int count) =>
      '$dateLabel • $count log${count == 1 ? '' : 's'}';
  static const contributionHeatmapWeekdayLabels = [
    'M',
    '',
    'W',
    '',
    'F',
    '',
    'S',
  ];
  static String contributionTooltip(String dateLabel, int count) =>
      '$dateLabel: $count log${count == 1 ? '' : 's'}';

  static const settingsScreenTitle = 'Settings';
  static const appearance = 'Appearance';
  static const theme = 'Theme';
  static const dark = 'Dark';
  static const light = 'Light';
  static const system = 'System';
  static const data = 'Data';
  static const exportDataAsJson = 'Export progress report';
  static const saveAllLogsToJson = 'Save dailylog_report.docx';
  static const about = 'About';
  static const aboutEmoji = '📓';
  static const clearAllData = 'Clear all data';
  static const open = 'Open';
  static const exportDataTitle = 'Export Report';
  static const clearAllDataTitle = 'Clear all data?';
  static const clearAllDataMessage =
      'This will permanently delete every log. Consider exporting first.';
  static const allDataCleared = 'All data cleared';

  static String reportExported(String path) => 'Report saved to $path';
  static String errorWithDetails(Object error) => 'Error: $error';
}
