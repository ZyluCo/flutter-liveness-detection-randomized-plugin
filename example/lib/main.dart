import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeView(),
  ));
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String?> capturedImages = [];
  String? imgPath;
  bool allowDetectionSteps = true; // Toggle for testing

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(12),
        children: [
          if (imgPath != null) ...[
            const Text(
              'Result Liveness Detection',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            Align(
              child: SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(imgPath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
          // Toggle switch for detection steps
          Card(
            child: SwitchListTile(
              title: const Text('Allow Detection Steps'),
              subtitle: Text(
                allowDetectionSteps
                    ? 'Users must complete blink/smile steps'
                    : 'Direct face capture (no steps)',
              ),
              value: allowDetectionSteps,
              onChanged: (bool value) {
                setState(() {
                  allowDetectionSteps = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () async {
                final String? response =
                    await FlutterLivenessDetectionRandomizedPlugin.instance
                        .livenessDetection(
                  context: context,
                  config: LivenessDetectionConfig(
                    allowDetectionSteps:
                        allowDetectionSteps, // NEW: Configure detection steps
                    isEnableMaxBrightness:
                        true, // enable disable max brightness when taking face photo
                    durationLivenessVerify: allowDetectionSteps
                        ? 60
                        : 15, // Shorter timeout for direct capture
                    showDurationUiText:
                        false, // show or hide duration remaining when perfoming liveness detection
                    startWithInfoScreen:
                        allowDetectionSteps, // Skip info for direct capture
                    useCustomizedLabel:
                        false, // set to true value for enable 'customizedLabel', set to false to use default label
                    // provide an empty string if you want to pass the liveness challenge
                    customizedLabel: LivenessDetectionLabelModel(
                      blink:
                          '', // add empty string to skip/pass this liveness challenge
                      lookDown: '',
                      lookLeft: '',
                      lookRight: '',
                      lookUp:
                          'Tengok Atas', // example of customize label name for liveness challenge. it will replace default 'look up'
                      smile: null, // null value to use default label name
                    ),
                  ),
                  isEnableSnackBar:
                      true, // snackbar to notify either liveness is success or failed
                  shuffleListWithSmileLast:
                      true, // put 'smile' challenge always at the end of liveness challenge, if `useCustomizedLabel` is true, this automatically set to false
                  isDarkMode: false, // enable dark/light mode
                  showCurrentStep:
                      allowDetectionSteps, // Only show steps when enabled
                );
                if (mounted) {
                  setState(() {
                    imgPath = response; // result liveness
                  });
                }
              },
              label: Text(allowDetectionSteps
                  ? 'Liveness Detection with Steps'
                  : 'Quick Face Capture')),
          const SizedBox(height: 8),
          if (allowDetectionSteps)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '🔒 High Security Mode\nUsers will complete blink and smile verification',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '⚡️ Quick Capture Mode\nFace is captured immediately when detected',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
        ],
      )),
    );
  }
}
