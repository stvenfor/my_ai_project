import 'package:flutter/material.dart';
import 'package:module_music/model/local_song.dart';

/// P2 Mock 歌曲：绑定可真实播放的 HTTPS mp3。
abstract final class MusicMockData {
  static final songs = <LocalSong>[
    LocalSong(
      id: '1',
      title: 'Ya Ali - DJMaza.Com',
      artist: 'Zubeen',
      album: 'Gangster A Love Story',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      albumArtUrl: 'https://picsum.photos/seed/music1/300/300',
      albumArtAsset: MusicAssets.defaultBackground,
    ),
    LocalSong(
      id: '2',
      title: 'Ek Do Teen - DJMaza.Info',
      artist: 'Parry G, Shreya Ghoshal',
      album: 'Baaghi 2',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      placeholderColor: Colors.deepPurple,
    ),
    LocalSong(
      id: '3',
      title: '16 yeh dil diwana hai',
      artist: '16 yeh dil diwana hai',
      album: 'Single',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      placeholderColor: Colors.indigo,
    ),
    LocalSong(
      id: '4',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      album: 'Divide',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      albumArtUrl: 'https://picsum.photos/seed/music4/300/300',
      albumArtAsset: MusicAssets.defaultCover,
    ),
    LocalSong(
      id: '5',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      album: 'After Hours',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      placeholderColor: Colors.blue,
    ),
    LocalSong(
      id: '6',
      title: 'Levitating',
      artist: 'Dua Lipa',
      album: 'Future Nostalgia',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      albumArtUrl: 'https://picsum.photos/seed/music6/300/300',
    ),
    LocalSong(
      id: '7',
      title: 'Stay',
      artist: 'The Kid LAROI & Justin Bieber',
      album: 'F*CK LOVE 3',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      placeholderColor: Colors.cyan,
    ),
    LocalSong(
      id: '8',
      title: 'Peaches',
      artist: 'Justin Bieber',
      album: 'Justice',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      placeholderColor: Colors.teal,
    ),
    LocalSong(
      id: '9',
      title: 'Bad Habits',
      artist: 'Ed Sheeran',
      album: '=',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      albumArtUrl: 'https://picsum.photos/seed/music9/300/300',
    ),
    LocalSong(
      id: '10',
      title: 'Shivers',
      artist: 'Ed Sheeran',
      album: '=',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      placeholderColor: Colors.green,
    ),
  ];
}
