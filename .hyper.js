module.exports = {
  config: {
    fontSize: 12,
    fontFamily: 'Odisseia, Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',
    cursorColor: '#ff43a1',
    cursorShape: 'BLOCK', // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    foregroundColor: '#ffffff',
    backgroundColor: '#152638',
    borderColor: '#333',
    padding: '12px 14px',

    css: '',
    termCSS: `
      @keyframes blink {
        from { opacity: 0.1 }
        to { opacity: 0.8 }
      }

      .cursor-node {
        animation: 0.5s blink linear infinite alternate;
        border-radius: 2px;
      }
    `,

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#152638',
      red: '#fc4349',
      green: '#40ea37',
      yellow: '#fecb57',
      blue: '#6391bf',
      magenta: '#cc00ff',
      cyan: '#00ffff',
      white: '#d0d0d0',
      lightBlack: '#808080',
      lightRed: '#ff0000',
      lightGreen: '#33ff00',
      lightYellow: '#ffff00',
      lightBlue: 'red',
      lightMagenta: '#cc00ff',
      lightCyan: '#00ffff',
      lightWhite: '#ffffff'
    },

    bell: 'SOUND',  // set to false for no bell
    // bellSoundURL: 'http://example.com/bell.mp3',

    // if true, selected text will automatically be copied to the clipboard
    copyOnSelect: false,

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: '',

    // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
    // by default ['--login'] will be used
    shellArgs: ['--login'],

    // for environment variables
    env: {}

    // for advanced config flags please refer to https://hyper.is/#cfg
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  plugins: [],

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
