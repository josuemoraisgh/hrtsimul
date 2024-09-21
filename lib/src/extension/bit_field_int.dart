extension BitFieldInt on int {
  static int _bitMask(int pos, int lenght) => ((1 << lenght) - 1) << pos;

  int getBits(int pos, int length) {
    final mask = _bitMask(pos, length);
    return (this & mask) >> pos;
  }

  int setBits(int pos, int length, int value) {
    final mask = _bitMask(pos, length);
    return (this & ~mask) | ((value << pos) & mask);
  }
}


