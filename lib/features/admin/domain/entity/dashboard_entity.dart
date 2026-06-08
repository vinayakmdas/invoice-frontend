class DashboardStats {
  final int totalUsers;
  final int pendingApprovals;
  final int approvedUsers;
  final int rejectedUsers;
  final int totalInvoices;
  final double totalRevenue;

  const DashboardStats({
    required this.totalUsers,
    required this.pendingApprovals,
    required this.approvedUsers,
    required this.rejectedUsers,
    required this.totalInvoices,
    required this.totalRevenue,
  });
}
