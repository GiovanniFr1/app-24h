from django.urls import path

from .views import TripAcceptView, TripCancelView, TripCompleteView, TripHistoryView, TripRequestView, TripStartView

urlpatterns = [
    path("", TripHistoryView.as_view(), name="trips-history"),
    path("request/", TripRequestView.as_view(), name="trips-request"),
    path("<int:trip_id>/accept/", TripAcceptView.as_view(), name="trips-accept"),
    path("<int:trip_id>/start/", TripStartView.as_view(), name="trips-start"),
    path("<int:trip_id>/complete/", TripCompleteView.as_view(), name="trips-complete"),
    path("<int:trip_id>/cancel/", TripCancelView.as_view(), name="trips-cancel"),
]
