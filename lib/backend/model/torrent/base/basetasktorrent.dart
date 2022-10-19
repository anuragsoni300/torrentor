abstract class BaseTaskTorrent {
  void resume();
  void pause();
  Future<void> start();
  void stop();
  void findingPublicTrackers();
  void addDhtNodes();
  void values();
}
