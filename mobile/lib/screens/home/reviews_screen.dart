import 'package:blood_donation/models/auth.dart';
import 'package:blood_donation/provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:blood_donation/models/user.dart';
import 'package:blood_donation/services/user.dart';
import 'package:blood_donation/theme/theme.dart';
import 'package:provider/provider.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  GetProfileResponseData? data;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    UserResponseData? user = context.read<GlobalState>().user;

    try {
      setState(() => loading = true);
      var res = await UserService.getProfile(id: user?.id ?? '');
      setState(() => data = res.data);
    } catch (e) {
      setState(() => error = true);
    } finally {
      setState(() => loading = false);
    }
  }

  Widget buildReviewItem(ProfileReviewData? reviewData) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      title: Text('${reviewData?.createdBy.name} Says'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reviewData?.review ?? ''),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                reviewData?.rating.toString() ?? '',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(width: 5.0),
              const Icon(Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLoadingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  Widget buildErrorWidget() {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 8.0),
          Text('Something Went Wrong', style: textTheme.titleLarge),
          const SizedBox(height: 12.0),
          ElevatedButton.icon(
            onPressed: fetchData,
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget buildDetailWidget() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: data?.reviews.length ?? 0,
      itemBuilder: (context, index) {
        return buildReviewItem(data?.reviews[index]);
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Reviews')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await fetchData(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPagePadding,
              ),
              child: Column(
                children: [
                  Visibility(
                    visible: loading && !error && data == null,
                    child: buildLoadingWidget(),
                  ),
                  Visibility(
                    visible: error && !loading,
                    child: buildErrorWidget(),
                  ),
                  Visibility(
                    visible: data != null && !loading,
                    child: buildDetailWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
