abstract class LocaleKeys {
  LocaleKeys._();

  // ── app ───────────────────────────────────────────────────────────────────
  static const appTitle = 'app.title';

  // ── time ──────────────────────────────────────────────────────────────────
  static const timeMorning = 'time.morning';
  static const timeDay = 'time.day';
  static const timeEvening = 'time.evening';
  static const timeNight = 'time.night';
  static const timeMonday = 'time.monday';
  static const timeTuesday = 'time.tuesday';
  static const timeWednesday = 'time.wednesday';
  static const timeThursday = 'time.thursday';
  static const timeFriday = 'time.friday';
  static const timeSaturday = 'time.saturday';
  static const timeSunday = 'time.sunday';

  // ── home ──────────────────────────────────────────────────────────────────
  static const homeStatistics = 'home.statistics';
  static const homeStatisticsHours = 'home.statisticsHours';
  static const homeLibrary = 'home.library';
  static const homeLibraryTracks = 'home.libraryTracks';
  static const homeHistory = 'home.history';
  static const homeHistoryEmpty = 'home.historyEmpty';
  static const homePlaylist = 'home.playlist';
  static const homeViewAll = 'home.viewAll';
  static const homeNewPlaylist = 'home.newPlaylist';
  static const homeHistorySidebar = 'home.historySidebar';

  // ── common ────────────────────────────────────────────────────────────────
  static const commonSearch = 'common.search';
  static const commonAdd = 'common.add';
  static const commonClose = 'common.close';
  static const commonLoading = 'common.loading';
  static const commonError = 'common.error';
  static const commonEmpty = 'common.empty';

  // ── import ────────────────────────────────────────────────────────────────
  static const importTitle = 'import.title';
  static const importSelectSource = 'import.selectSource';
  static const importSourceSelected = 'import.sourceSelected';
  static const importFromClipboard = 'import.fromClipboard';
  static const importLocalFile = 'import.localFile';
  static const importSoundCloud = 'import.soundCloud';

  // ── playlist ──────────────────────────────────────────────────────────────
  static const playlistCreateTitle = 'playlist.create.title';
  static const playlistCreateCover = 'playlist.create.cover';
  static const playlistCreateAddCover = 'playlist.create.addCover';
  static const playlistCreateName = 'playlist.create.name';
  static const playlistCreateButton = 'playlist.create.button';
  static const playlistNotFound = 'playlist.notFound';
  static const playlistFilesDuration = 'playlist.files.duration';
  static const playlistFilesAlbum = 'playlist.files.album';
  static const playlistFilesYear = 'playlist.files.year';
  static const playlistFilesAdded = 'playlist.files.added';
  static const playlistFilesSuccess = 'playlist.files.success';
  static const playlistFilesPartial = 'playlist.files.partial';

  // ── search ────────────────────────────────────────────────────────────────
  static const searchArtists = 'search.artists';

  // ── track ─────────────────────────────────────────────────────────────────
  static const trackData = 'track.data';
  static const trackDuration = 'track.duration';
  static const trackAlbum = 'track.album';
  static const trackYear = 'track.year';
  static const trackLinkInClipboard = 'track.linkInClipboard';
  static const trackAdd = 'track.add';
  static const trackFailedToLoad = 'track.failedToLoad';
  static const trackUnavailable = 'track.unavailable';
  static const trackRetry = 'track.retry';
  static const trackCancel = 'track.cancel';

  // ── snackbar ──────────────────────────────────────────────────────────────
  static const snackTrackAdded = 'snackbar.trackAdded';
  static const snackTrackAddedSub = 'snackbar.trackAddedSub';
  static const snackDownloading = 'snackbar.downloading';
  static const snackDownloadingSub = 'snackbar.downloadingSub';
  static const snackPlaylistCreated = 'snackbar.playlistCreated';
  static const snackErrorNetwork = 'snackbar.errorNetwork';
  static const snackErrorLoad = 'snackbar.errorLoad';
  static const snackErrorGeneric = 'snackbar.errorGeneric';
  static const snackCopied = 'snackbar.copied';
  static const snackSaved = 'snackbar.saved';

  // ── player ────────────────────────────────────────────────────────────────
  static const playerUnknownTitle = 'player.unknownTitle';
  static const playerUnknownArtist = 'player.unknownArtist';
  static const playerNowPlaying = 'player.nowPlaying';
  static const playerQueue = 'player.queue';
  static const playerShuffle = 'player.shuffle';
  static const playerRepeat = 'player.repeat';
  static const playerRepeatOne = 'player.repeatOne';

  // ── wave ──────────────────────────────────────────────────────────────────
  static const waveTitle = 'wave.title';
  static const waveSeedsLabel = 'wave.seedsLabel';
  static const waveGenerating = 'wave.generating';
  static const waveEmpty = 'wave.empty';
  static const waveSeedsActive = 'wave.seedsActive';

  // ── moods ─────────────────────────────────────────────────────────────────
  static const moodMelancholy = 'moods.melancholy';
  static const moodEnergy = 'moods.energy';
  static const moodFocus = 'moods.focus';
  static const moodNight = 'moods.night';
  static const moodDrive = 'moods.drive';

  // ── library ───────────────────────────────────────────────────────────────
  static const libraryTitle = 'library.title';
  static const libraryFilterAll = 'library.filterAll';
  static const libraryFilterYoutube = 'library.filterYoutube';
  static const libraryFilterLocal = 'library.filterLocal';
  static const libraryFilterSoundcloud = 'library.filterSoundcloud';
  static const libraryEmpty = 'library.empty';
  static const libraryEmptySub = 'library.emptySub';

  // ── statistics ────────────────────────────────────────────────────────────
  static const statsTotalTracks = 'statistics.totalTracks';
  static const statsTotalTime = 'statistics.totalTime';
  static const statsUniqueArtists = 'statistics.uniqueArtists';
  static const statsPeriodToday = 'statistics.periodToday';
  static const statsPeriodWeek = 'statistics.periodWeek';
  static const statsPeriodTwoWeeks = 'statistics.periodTwoWeeks';
  static const statsPeriodMonth = 'statistics.periodMonth';
  static const statsPeriodAll = 'statistics.periodAll';

  // ── errors ────────────────────────────────────────────────────────────────
  static const errorYoutube = 'errors.youtube';
  static const errorFileNotFound = 'errors.fileNotFound';
  static const errorNoInternet = 'errors.noInternet';
  static const errorUnknown = 'errors.unknown';
}
