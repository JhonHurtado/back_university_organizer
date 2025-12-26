import 'package:flutter/foundation.dart';
import '../models/period.dart';
import '../services/academic_service.dart';
import '../database/daos/period_dao.dart';
import '../database/app_database.dart';

/// Provider for managing period state with cache-first strategy
class PeriodProvider extends ChangeNotifier {
  final AcademicService _academicService;
  final PeriodDao _periodDao;

  PeriodProvider(this._academicService)
      : _periodDao = PeriodDao(AppDatabase.instance);

  List<Period> _periods = [];
  Period? _currentPeriod;
  bool _isLoading = false;
  String? _error;
  String? _currentCareerId;

  List<Period> get periods => _periods;
  Period? get currentPeriod => _currentPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load periods for a career with cache-first strategy
  Future<void> loadPeriodsByCareer(String careerId, {bool forceRefresh = false}) async {
    if (_isLoading && _currentCareerId == careerId && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      _currentCareerId = careerId;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        final cachedPeriods = await _periodDao.getByCareerId(careerId);
        if (cachedPeriods.isNotEmpty) {
          _periods = cachedPeriods;
          _currentPeriod = await _periodDao.getCurrentPeriod(careerId);
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedPeriods.length} periods from cache');

          // Fetch fresh data in background
          _fetchAndCachePeriods(careerId);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCachePeriods(careerId);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading periods: $e');

      // Try to load expired cache as fallback
      final expiredCache = await _periodDao.getByCareerId(careerId, includeExpired: true);
      if (expiredCache.isNotEmpty) {
        _periods = expiredCache;
        _currentPeriod = await _periodDao.getCurrentPeriod(careerId);
        debugPrint('⚠️  Loaded ${expiredCache.length} periods from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch periods from API and cache them
  Future<void> _fetchAndCachePeriods(String careerId) async {
    try {
      final response = await _academicService.getPeriodsByCareer(careerId);
      final periods = response.map((json) => Period.fromJson(json)).toList();

      // Cache the periods
      await _periodDao.insertOrUpdateBatch(periods);

      _periods = periods;

      // Load current period
      final currentPeriodResponse = await _academicService.getCurrentPeriod(careerId);
      _currentPeriod = Period.fromJson(currentPeriodResponse);

      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${periods.length} periods from API');
    } catch (e) {
      debugPrint('❌ Error fetching periods from API: $e');
      rethrow;
    }
  }

  /// Get period by ID with cache-first strategy
  Future<Period?> getPeriodById(String periodId) async {
    try {
      // Try cache first
      final cached = await _periodDao.getById(periodId);
      if (cached != null) {
        debugPrint('📦 Loaded period from cache: ${cached.name}');
        return cached;
      }

      // If not in cache, try to find in memory
      final memoryPeriod = _periods.firstWhere(
        (p) => p.id == periodId,
        orElse: () => throw Exception('Period not found'),
      );

      debugPrint('📝 Found period in memory: ${memoryPeriod.name}');
      return memoryPeriod;
    } catch (e) {
      debugPrint('❌ Error getting period: $e');
      return null;
    }
  }

  /// Get current period for a career
  Future<Period?> getCurrentPeriod(String careerId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _currentPeriod != null) {
        return _currentPeriod;
      }

      // Try cache first
      final cached = await _periodDao.getCurrentPeriod(careerId);
      if (cached != null && !forceRefresh) {
        _currentPeriod = cached;
        notifyListeners();
        debugPrint('📦 Loaded current period from cache: ${cached.name}');
        return cached;
      }

      // Fetch from API
      final response = await _academicService.getCurrentPeriod(careerId);
      final period = Period.fromJson(response);

      // Cache it
      await _periodDao.insertOrUpdate(period);

      _currentPeriod = period;
      notifyListeners();

      debugPrint('🌐 Fetched current period from API: ${period.name}');
      return period;
    } catch (e) {
      debugPrint('❌ Error getting current period: $e');
      return null;
    }
  }

  /// Create a new period
  Future<bool> createPeriod({
    required String careerId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _academicService.createPeriod(
        careerId: careerId,
        name: name,
        startDate: startDate,
        endDate: endDate,
      );

      final period = Period.fromJson(response);

      // Cache the new period
      await _periodDao.insertOrUpdate(period);

      // Reload periods for this career
      await loadPeriodsByCareer(careerId, forceRefresh: true);

      debugPrint('✅ Period created: ${period.name}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating period: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get active periods (periods that are currently ongoing)
  List<Period> getActivePeriods() {
    return _periods.where((p) => p.isActive).toList();
  }

  /// Clear all cached periods
  Future<void> clearCache() async {
    await _periodDao.clearAll();
    _periods = [];
    _currentPeriod = null;
    notifyListeners();
    debugPrint('🗑️  Period cache cleared');
  }

  /// Clear cached periods for a specific career
  Future<void> clearCacheForCareer(String careerId) async {
    await _periodDao.clearByCareer(careerId);
    if (_currentCareerId == careerId) {
      _periods = [];
      _currentPeriod = null;
      notifyListeners();
    }
    debugPrint('🗑️  Period cache cleared for career: $careerId');
  }
}
