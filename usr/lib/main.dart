import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GameApp());
}

// --- Game State Management (Simulation of Backend) ---
class GameState extends ChangeNotifier {
  // Economy
  double balanceUsd = 0.0; // Real money balance (from referrals/withdrawals)
  int coins = 100; // Game currency
  int energy = 100;
  int maxEnergy = 100;
  
  // VIP System
  bool isVip = false;
  
  // Referral System
  int invitedFriends = 0;
  String referralCode = "USER-${Random().nextInt(9999)}";

  // Tasks & Achievements
  List<GameTask> dailyTasks = [
    GameTask(id: 1, title: "اجمع 500 كوينز", target: 500, rewardCoins: 100),
    GameTask(id: 2, title: "ادعُ صديقاً واحداً", target: 1, rewardCoins: 300),
    GameTask(id: 3, title: "العب لمدة 5 دقائق", target: 5, rewardCoins: 50),
  ];

  List<Achievement> achievements = [
    Achievement(id: 1, title: "البداية", description: "وصل رصيدك إلى 1000 كوينز", target: 1000, rewardUsd: 0.5),
    Achievement(id: 2, title: "المليونير", description: "اجمع مليون كوينز", target: 1000000, rewardUsd: 50.0),
  ];

  // Timer for energy regeneration
  Timer? _energyTimer;

  GameState() {
    _startEnergyRegen();
  }

  void _startEnergyRegen() {
    _energyTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (energy < maxEnergy) {
        energy++;
        notifyListeners();
      }
    });
  }

  // Core Gameplay
  void clickToEarn() {
    if (energy > 0 || isVip) {
      // VIP gets double earnings and unlimited energy logic (simulated by not reducing energy)
      int earnings = isVip ? 20 : 10;
      coins += earnings;
      
      if (!isVip) {
        energy--;
      }
      
      // Update task progress (simplified)
      _updateTaskProgress(1, earnings); 
      _checkAchievements();
      
      notifyListeners();
    }
  }

  void _updateTaskProgress(int taskId, int amount) {
    // Logic to update specific task progress would go here
  }

  void _checkAchievements() {
    for (var ach in achievements) {
      if (!ach.isUnlocked && coins >= ach.target) {
        ach.isUnlocked = true;
        balanceUsd += ach.rewardUsd;
        // Notify user logic here
      }
    }
  }

  // Shop & VIP
  void buyVip() {
    if (balanceUsd >= 10.0) { // Cost $10
      balanceUsd -= 10.0;
      isVip = true;
      notifyListeners();
    }
  }

  void buyCoins(double cost, int amount) {
    // Simulation of In-App Purchase
    // In a real app, this would trigger the payment gateway
    coins += amount;
    notifyListeners();
  }

  // Referrals
  void inviteFriend() {
    // Simulation: User shares link, friend joins
    invitedFriends++;
    balanceUsd += 1.0; // Earn $1 per friend
    _updateTaskProgress(2, 1);
    notifyListeners();
  }

  // Wallet
  String withdraw(double amount) {
    if (amount <= 0) return "أدخل مبلغاً صحيحاً";
    if (balanceUsd >= amount) {
      balanceUsd -= amount;
      notifyListeners();
      return "تم تقديم طلب السحب بنجاح! سيصلك خلال 24 ساعة.";
    } else {
      return "رصيدك غير كافٍ للسحب.";
    }
  }
}

class GameTask {
  final int id;
  final String title;
  final int target;
  int current = 0;
  final int rewardCoins;
  bool isClaimed = false;

  GameTask({required this.id, required this.title, required this.target, required this.rewardCoins});
}

class Achievement {
  final int id;
  final String title;
  final String description;
  final int target;
  final double rewardUsd;
  bool isUnlocked = false;

  Achievement({required this.id, required this.title, required this.description, required this.target, required this.rewardUsd});
}

// --- UI Components ---

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  final GameState _gameState = GameState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gameState,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'لعبة الربح الشاملة',
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.amber,
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            colorScheme: ColorScheme.dark(
              primary: Colors.amber,
              secondary: Colors.purpleAccent,
              surface: const Color(0xFF16213E),
            ),
            fontFamily: 'Arial', // Use a standard font for now
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => MainScreen(gameState: _gameState),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final GameState gameState;
  const MainScreen({super.key, required this.gameState});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(gameState: widget.gameState),
      TasksPage(gameState: widget.gameState),
      TournamentPage(gameState: widget.gameState),
      StorePage(gameState: widget.gameState),
      WalletPage(gameState: widget.gameState),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F3460),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'اللعب'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'البطولات'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
        ],
      ),
    );
  }
}

// --- 1. Home Page (Clicker & VIP) ---
class HomePage extends StatelessWidget {
  final GameState gameState;
  const HomePage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gameState.isVip 
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.purple.shade900],
              ),
            )
          : null,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("الرصيد: \$${gameState.balanceUsd.toStringAsFixed(2)}", 
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("الكوينز: ${gameState.coins}", 
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                if (gameState.isVip)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                    child: const Text("VIP MEMBER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => VipDialog(gameState: gameState),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text("ترقية VIP", style: TextStyle(color: Colors.black)),
                  ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Clicker Button
          GestureDetector(
            onTap: gameState.clickToEarn,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gameState.isVip ? Colors.purple : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: (gameState.isVip ? Colors.purple : Colors.blue).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Icon(
                  Icons.touch_app, 
                  size: 80, 
                  color: Colors.white
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Text(
            gameState.isVip ? "طاقة غير محدودة!" : "الطاقة: ${gameState.energy}/${gameState.maxEnergy}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (!gameState.isVip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: LinearProgressIndicator(
                value: gameState.energy / gameState.maxEnergy,
                backgroundColor: Colors.grey[800],
                color: Colors.blue,
                minHeight: 10,
              ),
            ),
            
          const Spacer(),
          const Text("اضغط للكسب!", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class VipDialog extends StatelessWidget {
  final GameState gameState;
  const VipDialog({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("نظام VIP المميز", textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(leading: Icon(Icons.flash_on, color: Colors.amber), title: Text("طاقة غير محدودة")),
          ListTile(leading: Icon(Icons.attach_money, color: Colors.green), title: Text("مضاعفة الأرباح x2")),
          ListTile(leading: Icon(Icons.palette, color: Colors.purple), title: Text("ثيم ذهبي خاص")),
          Divider(),
          Text("السعر: 10 دولار فقط", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
        ElevatedButton(
          onPressed: () {
            if (gameState.balanceUsd >= 10) {
              gameState.buyVip();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تفعيل VIP بنجاح!")));
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("رصيدك غير كافٍ")));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text("شراء الآن", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

// --- 2. Tasks & Achievements ---
class TasksPage extends StatelessWidget {
  final GameState gameState;
  const TasksPage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "المهام اليومية"),
              Tab(text: "الإنجازات"),
            ],
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Daily Tasks
                ListView.builder(
                  itemCount: gameState.dailyTasks.length,
                  itemBuilder: (context, index) {
                    final task = gameState.dailyTasks[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: const Color(0xFF16213E),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
                        title: Text(task.title),
                        subtitle: Text("المكافأة: ${task.rewardCoins} كوينز"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Claim logic mock
                          },
                          child: const Text("استلام"),
                        ),
                      ),
                    );
                  },
                ),
                // Achievements
                ListView.builder(
                  itemCount: gameState.achievements.length,
                  itemBuilder: (context, index) {
                    final ach = gameState.achievements[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: ach.isUnlocked ? Colors.green.withOpacity(0.2) : const Color(0xFF16213E),
                      child: ListTile(
                        leading: Icon(Icons.emoji_events, color: ach.isUnlocked ? Colors.amber : Colors.grey),
                        title: Text(ach.title),
                        subtitle: Text(ach.description),
                        trailing: ach.isUnlocked 
                            ? const Icon(Icons.check, color: Colors.green)
                            : Text("\$${ach.rewardUsd}", style: const TextStyle(color: Colors.greenAccent)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Tournaments ---
class TournamentPage extends StatelessWidget {
  final GameState gameState;
  const TournamentPage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          color: Colors.deepPurple,
          child: Column(
            children: const [
              Text("🏆 بطولة الأسبوع 🏆", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              Text("الجائزة الكبرى: 500 دولار", style: TextStyle(fontSize: 18, color: Colors.amber)),
              Text("ينتهي خلال: 02:14:50", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildRankItem(1, "أحمد محمد", 150000),
              _buildRankItem(2, "سارة علي", 142000),
              _buildRankItem(3, "Player_99", 120000),
              _buildRankItem(4, "أنت (غير مصنف)", gameState.coins, isMe: true),
              _buildRankItem(5, "خالد", 90000),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.all(15)),
              child: const Text("انضم للبطولة (500 كوينز)", style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRankItem(int rank, String name, int score, {bool isMe = false}) {
    return Container(
      color: isMe ? Colors.amber.withOpacity(0.2) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey : Colors.brown),
          child: Text("#$rank", style: const TextStyle(color: Colors.black)),
        ),
        title: Text(name, style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
        trailing: Text("$score 🪙"),
      ),
    );
  }
}

// --- 4. Store ---
class StorePage extends StatelessWidget {
  final GameState gameState;
  const StorePage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("متجر الكوينز", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildStoreItem(context, "حزمة المبتدئ", "1,000 كوينز", "\$0.99", 1000),
        _buildStoreItem(context, "حزمة المحترف", "5,000 كوينز", "\$4.99", 5000),
        _buildStoreItem(context, "حزمة الثراء", "15,000 كوينز", "\$9.99", 15000),
        
        const Divider(height: 40),
        
        const Text("متجر الثيمات", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.color_lens, color: Colors.pink),
          title: const Text("ثيم النيون"),
          subtitle: const Text("5000 كوينز"),
          trailing: ElevatedButton(onPressed: () {}, child: const Text("شراء")),
        ),
      ],
    );
  }

  Widget _buildStoreItem(BuildContext context, String title, String amount, String price, int coins) {
    return Card(
      color: const Color(0xFF16213E),
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.amber, size: 40),
        title: Text(title),
        subtitle: Text(amount),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            // Mock purchase
            gameState.buyCoins(0, coins);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم شراء $amount بنجاح!")));
          },
          child: Text(price),
        ),
      ),
    );
  }
}

// --- 5. Wallet & Referrals ---
class WalletPage extends StatefulWidget {
  final GameState gameState;
  const WalletPage({super.key, required this.gameState});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController _withdrawController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blueGrey]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text("الرصيد القابل للسحب", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text("\$${widget.gameState.balanceUsd.toStringAsFixed(2)}", 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Mock Deposit
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("بوابة الدفع غير متصلة (تجريبي)")));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("شحن"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showWithdrawDialog(context),
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text("سحب"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Referral Section
          const Text("نظام الإحالة (اربح \$1 لكل صديق)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Text("كود الدعوة الخاص بك:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                SelectableText(
                  widget.gameState.referralCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.gameState.referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نسخ الكود!")));
                    
                    // Simulate a friend joining for demo purposes
                    widget.gameState.inviteFriend();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تجريبي: انضم صديق جديد! (+1 دولار)")));
                  },
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: const Text("نسخ ومشاركة الرابط", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 45)),
                ),
                const SizedBox(height: 10),
                Text("عدد المدعوين: ${widget.gameState.invitedFriends}", style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("سحب الأرباح"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("أدخل المبلغ المراد سحبه:"),
            TextField(
              controller: _withdrawController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: "\$ "),
            ),
            const SizedBox(height: 10),
            const Text("طرق السحب المتاحة: PayPal, USDT, Bank Transfer", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              double? amount = double.tryParse(_withdrawController.text);
              if (amount != null) {
                String result = widget.gameState.withdraw(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: const Text("تأكيد السحب"),
          ),
        ],
      ),
    );
  }
}
