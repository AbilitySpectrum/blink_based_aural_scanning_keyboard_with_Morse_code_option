
// read text from pre-loaded mp3 files
void sayWords ( String s ) {
  if ( voiceon ) {
    int i=menuObj.getJSONObject( s ).getInt("sound");
    lastPresented = millis() + 1500;
    sounds[i].play();
    sounds[i].rewind();
  }
}

void readIt() {
  String txt = "";

  for ( int i=0; i<=currentLine; i++ ) {
    txt += textlines[i] + " ";
  }
  pauseFor( 100*txt.length(), false);
  lastPresented = millis();
  lastPresented += 300*txt.length() + 6000; 

  delay(1000); /// Jan 27
  
  if ( useGoogle ) {
    readByGoogle(txt);
  } else if ( useBrowser ) {
    readByBrowser(txt);
  } else {
    readByEspeak(txt);
  }
}

// read text using espeak
void readByEspeak(String txt) {

  try {
    String[] args1 = {
      //"/usr/local/bin/speak", "-ven+f4", "-g 7", txt
      "say", "-v", "karen", txt // "vicki", "-r", "200", txt
    };
    Runtime r = Runtime.getRuntime();
    Process p = r.exec(args1);
    delay(500);
  } 
  catch (IOException ex) {
    println(ex.toString());
  }
}

void readByBrowser(String txt) {

  try {
    String[] args1 = {
      "open", "/Applications/Google Chrome.app", 
      "file:///Users/ylh/0/node/blink/speak.html?txt=" +
        txt
    };
    print("use speack syntheses: " + txt + "+++");
    Runtime r = Runtime.getRuntime();
    Process p = r.exec(args1);
  }  
  catch (IOException ex) {
    println(ex.toString());
  }
}

void readByGoogle(String txt) {

  try {
    String[] args1 = {

      "curl", "-A ", "Mozilla", 
      "https://translate.google.com/translate_tts?tl=en&q=" +
        txt
    };
    println(txt);
    Runtime r = Runtime.getRuntime();
    Process p = r.exec(args1);

    //http://www.ask-coder.com/1527922/java-file-redirection-both-ways-within-runtime-exec
    //   Process proc = Runtime.getRuntime().exec("...");
    InputStream standardOutputOfChildProcess = p.getInputStream();
    OutputStream dataToFile = new FileOutputStream("tmp.mp3");

    byte[] buff = new byte[1024];
    for ( int count = -1; (count = standardOutputOfChildProcess.read (buff)) != -1; ) {
      dataToFile.write(buff, 0, count);
    }

    dataToFile.close();

    delay(500);
    println( args1 );
    gMinim = new Minim( this );
    AudioPlayer s = gMinim.loadFile("tmp.mp3");
    s.play();
  } 
  catch (IOException ex) {
    println(ex.toString());
  }
}


/*

 http://espeak.sourceforge.net/commands.html
 
 YLH: speak "could you please get me some coffee?" -ven+f1 -g 7 -s 170 -p 55
 
 2.2.1 Examples
 
 To use at the command line, type:
 espeak "This is a test"
 or
 espeak -f <text file>
 Or just type
 espeak
 followed by text on subsequent lines. Each line is spoken when RETURN is pressed.
 
 Use espeak -x to see the corresponding phoneme codes.
 
 
 
 2.2.2 The Command Line Options
 
 espeak [options] ["text words"]
 Text input can be taken either from a file, from a string in the command, or from stdin.
 -f <text file>
 Speaks a text file.
 --stdin
 Takes the text input from stdin.
 If neither -f nor --stdin is given, then the text input is taken from "text words" (a text string within double quotes). 
 If that is not present then text is taken from stdin, but each line is treated as a separate sentence.
 -a <integer>
 Sets amplitude (volume) in a range of 0 to 200. The default is 100.
 -p <integer>
 Adjusts the pitch in a range of 0 to 99. The default is 50.
 -s <integer>
 Sets the speed in words-per-minute (approximate values for the default English voice, others may differ slightly). The default value is 175. I generally use a faster speed of 260. The lower limit is 80. There is no upper limit, but about 500 is probably a practical maximum.
 -b <integer>
 Input text character format.
 1   UTF-8. This is the default.
 
 2   The 8-bit character set which corresponds to the language (eg. Latin-2 for Polish).
 
 4   16 bit Unicode.
 
 Without this option, eSpeak assumes text is UTF-8, but will automatically switch to the 8-bit character set if it finds an illegal UTF-8 sequence.
 
 -g <integer>
 Word gap. This option inserts a pause between words. The value is the length of the pause, in units of 10 mS (at the default speed of 170 wpm).
 -h or --help
 The first line of output gives the eSpeak version number.
 -k <integer>
 Indicate words which begin with capital letters.
 1   eSpeak uses a click sound to indicate when a word starts with a capital letter, or double click if word is all capitals.
 
 2   eSpeak speaks the word "capital" before a word which begins with a capital letter.
 
 Other values:   eSpeak increases the pitch for words which begin with a capital letter. The greater the value, the greater the increase in pitch. Try -k20.
 
 -l <integer>
 Line-break length, default value 0. If set, then lines which are shorter than this are treated as separate clauses and spoken separately with a break between them. This can be useful for some text files, but bad for others.
 -m
 Indicates that the text contains SSML (Speech Synthesis Markup Language) tags or other XML tags. Those SSML tags which are supported are interpreted. Other tags, including HTML, are ignored, except that some HTML tags such as <hr> <h2> and <li> ensure a break in the speech.
 -q
 Quiet. No sound is generated. This may be useful with options such as -x and --pho.
 -v <voice filename>[+<variant>]
 Sets a Voice for the speech, usually to select a language. eg:
 espeak -vaf
 To use the Afrikaans voice. A modifier after the voice name can be used to vary the tone of the voice, eg:
 espeak -vaf+3
 The variants are +m1 +m2 +m3 +m4 +m5 +m6 +m7 for male voices and +f1 +f2 +f3 +f4 which simulate female voices by using higher pitches. Other variants include +croak and +whisper.
 <voice filename> is a file within the espeak-data/voices directory.
 <variant> is a file within the espeak-data/voices/!v directory.
 
 Voice files can specify a language, alternative pronunciations or phoneme sets, different pitches, tonal qualities, and prosody for the voice. See the voices.html file.
 
 Voice names which start with mb- are for use with Mbrola diphone voices, see mbrola.html
 
 Some languages may need additional dictionary data, see languages.html
 
 -w <wave file>
 Writes the speech output to a file in WAV format, rather than speaking it.
 -x
 The phoneme mnemonics, into which the input text is translated, are written to stdout. If a phoneme name contains more than one letter (eg. [tS]), the --sep or --tie option can be used to distinguish this from separate phonemes.
 -X
 As -x, but in addition, details are shown of the pronunciation rule and dictionary list lookup. This can be useful to see why a certain pronunciation is being produced. Each matching pronunciation rule is listed, together with its score, the highest scoring rule being used in the translation. "Found:" indicates the word was found in the dictionary lookup list, and "Flags:" means the word was found with only properties and not a pronunciation. You can see when a word has been retranslated after removing a prefix or suffix.
 -z
 The option removes the end-of-sentence pause which normally occurs at the end of the text.
 --stdout
 Writes the speech output to stdout as it is produced, rather than speaking it. The data starts with a WAV file header which indicates the sample rate and format of the data. The length field is set to zero because the length of the data is unknown when the header is produced.
 --compile [=<voice name>]
 Compile the pronunciation rule and dictionary lookup data from their source files in the current directory. The Voice determines which language's files are compiled. For example, if it's an English voice, then en_rules, en_list, and en_extra (if present), are compiled to replace en_dict in the speak-data directory. If no Voice is specified then the default Voice is used.
 --compile-debug [=<voice name>]
 The same as --compile, but source line numbers from the *_rules file are included. These are included in the rules trace when the -X option is used.
 --ipa
 Writes phonemes to stdout, using the International Phonetic Alphabet (IPA).
 If a phoneme name contains more than one letter (eg. [tS]), the --sep or --tie option can be used to distinguish this from separate phonemes.
 --path [="<directory path>"]
 Specifies the directory which contains the espeak-data directory.
 --pho
 When used with an mbrola voice (eg. -v mb-en1), it writes mbrola phoneme data (.pho file format) to stdout. This includes the mbrola phoneme names with duration and pitch information, in a form which is suitable as input to this mbrola voice. The --phonout option can be used to write this data to a file.
 --phonout [="<filename>"]
 If specified, the output from -x, -X, --ipa, and --pho options is written to this file, rather than to stdout.
 --punct [="<characters>"]
 Speaks the names of punctuation characters when they are encountered in the text. If <characters> are given, then only those listed punctuation characters are spoken, eg. --punct=".,;?"
 --sep [=<character>]
 The character is used to separate individual phonemes in the output which is produced by the -x or --ipa options. The default is a space character. The character z means use a ZWNJ character (U+200c).
 --split [=<minutes>]
 Used with -w, it starts a new WAV file every <minutes> minutes, at the next sentence boundary.
 --tie [=<character>]
 The character is used within multi-letter phonemes in the output which is produced by the -x or --ipa options. The default is the tie character  ͡  U+361. The character z means use a ZWJ character (U+200d).
 --voices [=<language code>]
 Lists the available voices.
 If =<language code> is present then only those voices which are suitable for that language are listed.
 --voices=mbrola lists the voices which use mbrola diphone voices. These are not included in the default --voices list
 --voices=variant lists the available voice variants (voice modifiers).
 
 
 2.2.3 The Input Text
 
 HTML Input
 If the -m option is used to indicate marked-up text, then HTML can be spoken directly.
 Phoneme Input
 As well as plain text, phoneme mnemonics can be used in the text input to espeak. They are enclosed within double square brackets. Spaces are used to separate words and all stressed syllables must be marked explicitly.
 eg:   espeak -v en "[[D,Is Iz sVm f@n'EtIk t'Ekst 'InpUt]]"
 
 This command will speak: "This is some phonetic text input".
 
 */

