import React from 'react';
import { CloudIcon, ShieldCheckIcon, BriefcaseIcon, ExclamationTriangleIcon, BanknotesIcon } from '@heroicons/react/20/solid';

const FlightCard = ({ flight, questionableDelaysEnabled }) => {
    const formatDateTime = (dateTime) => {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
        }).format(new Date(dateTime));
    };

    const renderDelayIcon = (code) => {
        switch (code) {
            case '1':
                return <ExclamationTriangleIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
            case '2':
                return <BriefcaseIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
            case '3':
                return <CloudIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
            case '4':
                return <BanknotesIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
            case '5':
                return <ShieldCheckIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
            default:
                return <ExclamationTriangleIcon className="h-5 w-5 text-red-500" aria-hidden="true" />;
        }
    };

    const isQuestionableDelay = (flight) => {
        return questionableDelaysEnabled && flight.delays.length === 0 && new Date(flight.actual_departure_at) > new Date(flight.scheduled_departure_at);
    };

    const getDynamicDelay = (flight) => {
        if (isQuestionableDelay(flight)) {
            const delayMinutes = Math.round((new Date(flight.actual_departure_at) - new Date(flight.scheduled_departure_at)) / 60000);
            return {
                code: '1',
                description: 'Unknown reason',
                time_minutes: delayMinutes
            };
        }
        return null;
    };

    const DetailItem = ({ title, value, bgColor }) => (
        <div className={`px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 ${bgColor}`}>
            <dt className="text-sm font-medium text-gray-500">{title}</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{value}</dd>
        </div>
    );

    const dynamicDelay = getDynamicDelay(flight);

    return (
        <div className="bg-white shadow-lg border overflow-hidden sm:rounded-lg">
            <div className={`px-4 py-5 sm:px-6 ${flight.delays.length > 0 ? 'bg-red-200' : dynamicDelay ? 'bg-yellow-200' : 'bg-slate-300'}`}>
                <h3 className="text-lg leading-6 font-medium text-gray-900">Flight {flight.flight_number}</h3>
                <p className="mt-1 max-w-2xl text-sm text-gray-500">
                    Operated by {flight.airline.label}
                    <span className='font-bold text-xs ml-1'>{`(${flight.airline.code})`}</span>
                </p>
                {flight.marketing_flights.length > 0 && (
                    <div className="mt-2">
                        <h4 className="text-sm font-medium text-gray-700">Marketing Flights:</h4>
                        <ul className="list-disc list-inside text-sm text-gray-500">
                            {flight.marketing_flights.map((mf, index) => (
                                <li key={index}>{mf.airline} {mf.flight_number}</li>
                            ))}
                        </ul>
                    </div>
                )}
            </div>
            <div className="border-t border-gray-200">
                <dl>
                    <DetailItem
                        title="Origin"
                        value={`${flight.origin.label} (${flight.origin.code})`}
                        bgColor="bg-slate-100"
                    />
                    <DetailItem
                        title="Destination"
                        value={`${flight.destination.label} (${flight.destination.code})`}
                        bgColor="bg-white"
                    />
                    <DetailItem
                        title="Scheduled Departure"
                        value={formatDateTime(flight.scheduled_departure_at)}
                        bgColor="bg-slate-100"
                    />
                    {flight.actual_departure_at && (
                        <DetailItem
                            title="Actual Departure"
                            value={formatDateTime(flight.actual_departure_at)}
                            bgColor="bg-white"
                        />
                    )}
                    {flight.scheduled_arrival_at && (
                        <DetailItem
                            title="Scheduled Arrival"
                            value={formatDateTime(flight.scheduled_arrival_at)}
                            bgColor="bg-slate-100"
                        />
                    )}
                    {flight.actual_arrival_at && (
                        <DetailItem
                            title="Actual Arrival"
                            value={formatDateTime(flight.actual_arrival_at)}
                            bgColor="bg-white"
                        />
                    )}
                    {flight.estimated_arrival_at && (
                        <DetailItem
                            title="Estimated Arrival"
                            value={flight.estimated_arrival_at ? formatDateTime(flight.estimated_arrival_at) : 'N/A'}
                            bgColor="bg-slate-100"
                        />
                    )}
                    {(flight.delays.length > 0 || dynamicDelay) && (
                        <div className="bg-white px-4 py-5 sm:px-6">
                            <dt className="text-sm font-medium text-gray-500">Delays</dt>
                            {flight.delays.map((delay, index) => (
                                <dd key={index} className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 flex items-center">
                                    {renderDelayIcon(delay.code)}
                                    <span className="ml-2">{delay.description ? delay.description : "Unknown reason"} ({delay.time_minutes} minutes)</span>
                                </dd>
                            ))}
                            {dynamicDelay && (
                                <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 flex items-center">
                                    {renderDelayIcon(dynamicDelay.code)}
                                    <span className="ml-2">{dynamicDelay.description} ({dynamicDelay.time_minutes} minutes)</span>
                                </dd>
                            )}
                        </div>
                    )}
                </dl>
            </div>
        </div>
    );
};

export default FlightCard;
