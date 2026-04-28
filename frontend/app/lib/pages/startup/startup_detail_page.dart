/// Eduardo Kairalla - 24024241

/// Startup detail screen — tabs: About, Partners, Q&A, Video.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/widgets/widgets.dart';


// --- PAGE ---

class StartupDetailPage extends StatefulWidget {

  final String startupId;

  const StartupDetailPage({super.key, required this.startupId});

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {

  final StartupController _controller = StartupController();

  @override
  void initState() {
    super.initState();
    _controller.load(widget.startupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        if (_controller.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (_controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _controller.load(widget.startupId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final startup  = _controller.startup!;
        final userName = AppState.instance.profile?.fullName ?? 'Usuário';

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [

                  StartupHeader(startup: startup, userName: userName),

                  StartupInfoCard(startup: startup),

                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black38,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.black, width: 2.5),
                        insets: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline,        size: 18), text: 'Sobre'),
                        Tab(icon: Icon(Icons.people_outline,      size: 18), text: 'Sócios'),
                        Tab(icon: Icon(Icons.chat_bubble_outline, size: 18), text: 'Q&A'),
                        Tab(icon: Icon(Icons.play_circle_outline, size: 18), text: 'Vídeo'),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        AboutTab(startup: startup),
                        PartnersTab(startup: startup),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => QATab(
                            controller: _controller,
                            startupId:  widget.startupId,
                          ),
                        ),
                        VideoTab(videoUrl: startup.videoUrl),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Balcão de investimento em breve!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'INVESTIR NESTA STARTUP',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ),
        );
      },
    );
  }
}
