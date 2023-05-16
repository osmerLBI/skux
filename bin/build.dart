import 'dart:io';

void main() {
  var file = File('./build/web/index.html');
  var content = file.readAsStringSync();
  content = content.replaceAll('src="packages/', 'src="assets/packages/');

  var time = DateTime.now().millisecondsSinceEpoch;
  content =
      content.replaceFirst('src="main.dart.js"', 'src="main.dart.js?_=$time"');

  content = content.replaceFirst(r'''<link rel="manifest" href="manifest.json">
</head>''', r'''<link rel="manifest" href="manifest.json"><style>
    @keyframes flash {
      from {
        opacity: 0;
      }
      to {
        opacity: 1;
      }
    }
  </style>
</head>''');
  content = content.replaceFirst(r'''<body>
  <!-- This script''', r'''<body><div style="position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -70%);
    animation: flash 0.8s ease-in-out infinite alternate;
    text-align: center;">
    <img src="assets/assets/image/skux/logo_green.png" style="width: 120px" alt="">
  </div>
  <!-- This script''');

  file.writeAsString(content);
}
