//
//  MapVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

protocol MapVCDelegate {
    func mapVC(mapVC: MapVC, showDetailVCForAnnotation annotation:MKAnnotation)
}

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var delegate: MapVCDelegate?

    var crimes:Array<Report> = []
    var schools:Array<School> = []

    var schoolGradient:CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        schoolGradient = CAGradientLayer()
        schoolGradient!.colors = [UIColor.redColor().CGColor, UIColor.orangeColor().CGColor,UIColor.yellowColor().CGColor,UIColor.yellowColor().CGColor,UIColor.greenColor().CGColor]
        schoolGradient!.locations = [0.0 ,0.3,0.65,0.68, 1.0]
        schoolGradient?.startPoint = CGPoint(x: 0.0, y: 0.5)
        schoolGradient?.endPoint = CGPoint(x: 1.0, y: 0.5)

        mapView.delegate = self
//        mapView.mapType = .Hybrid
        //mapView.pitchEnabled = false

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.8570092871228, -87.6975366951543)
        let span = MKCoordinateSpanMake(0.4, 0.7)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)

        showBoundaryWithDataSet("chicago_boundaries_neighborhood")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let gradientView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        gradientView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        schoolGradient?.frame = gradientView.bounds
        gradientView.layer.insertSublayer(schoolGradient!, above: view.layer)

        view.insertSubview(gradientView, aboveSubview: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helper

    func addReports(reports: Array<Report>) {
        clearReports()

        crimes += reports
        mapView.addAnnotations(reports)
    }

    func clearReports() {
        mapView.removeAnnotations(crimes)
        crimes.removeAll()
    }

    func addSchools(schools: Array<School>) {
        clearSchools()

        self.schools += schools
        mapView.addAnnotations(schools)
    }

    func clearSchools() {
        mapView.removeAnnotations(schools)
        schools.removeAll()
    }

    func showBoundaryWithDataSet(set: String) {
        let path = NSBundle.mainBundle().pathForResource(set, ofType: "json")
        let json = JSON(data: NSData(contentsOfFile: path!)!)

        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            var communities:[[CLLocationCoordinate2D]] = []

            for (_, sJson) in json {
                var points:[CLLocationCoordinate2D] = []
                for (_, ssJson) in sJson["the_geom"]["coordinates"][0][0] {
                    points += [CLLocationCoordinate2DMake(ssJson[1].double!, ssJson[0].double!)]
                }

                communities += [points]
            }

            dispatch_async(dispatch_get_main_queue()){
                communities.forEach { (var community) -> () in
                    let poly = MKPolygon(coordinates: &community, count: community.count)

                    self.mapView.addOverlay(poly)
                }
            }
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is Report:
            return (annotation as! Report).mapAnnotationView()

        case is School:
            let annoView:MKPinAnnotationView = (annotation as! School).mapAnnotationView() as! MKPinAnnotationView

            let pinColor:UIColor = schoolGradient!.colorForRatio((annotation as! School).selectedAttributeFloat())
            annoView.pinTintColor = pinColor
            return annoView

        default:
            return nil
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView annotView: MKAnnotationView) {
        delegate?.mapVC(self, showDetailVCForAnnotation: annotView.annotation!)

        annotView.highlighted = true
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: poly)
            renderer.fillColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
            renderer.strokeColor = UIColor.blackColor()
            renderer.lineWidth = 2

            return renderer
        }
        
        return MKOverlayRenderer()
    }
}
