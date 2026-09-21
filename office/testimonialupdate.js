export const dynamic = "force-dynamic";

import { publishers } from "@/DB/publisherList";
import prisma from "@/prisma/client";
import { NextResponse } from "next/server";

const SOURCE_PREFIX = "dir";
const SOURCE_TESTIMONIAL_IDS = [214, 215, 216, 217, 218, 219, 220];

// Publishers that have the multi-language / localization feature enabled
const LOCALIZATION_SUPPORTED_PREFIXES = new Set([
    "amr",
    "miq",
    "sdi",
    "mra",
    "dim",
    "pmr",
]);

async function syncTestimonials() {
    // 1. Fetch source testimonials and their translations from 'dir'
    const sourceTestimonials = await prisma.testimonial.findMany({
        where: {
            prefix: SOURCE_PREFIX,
            id: { in: SOURCE_TESTIMONIAL_IDS },
        },
        include: {
            testimonialLocalizations: true,
        },
        orderBy: {
            id: "asc",
        },
    });

    if (sourceTestimonials.length === 0) {
        throw new Error(
            `No source testimonials found for prefix '${SOURCE_PREFIX}' with IDs: ${SOURCE_TESTIMONIAL_IDS.join(", ")}`
        );
    }

    // 2. Identify target publishers (all distinct prefixes excluding 'dir')
    const targetPrefixes = [
        "mrf",
        "amr",
        "dim",
        "pmr",
        "mra",
        "miq",
        "sdi",
        "mpu",
        "idi",
        "rih",
    ];

    console.log(
        `Starting sync of ${sourceTestimonials.length} testimonials to ${targetPrefixes.length} publishers: ${targetPrefixes.join(", ")}`
    );

    const results = [];

    for (const targetPrefix of targetPrefixes) {
        let createdCount = 0;
        let existingCount = 0;
        let localizationsSynced = 0;
        const supportsLocalization = LOCALIZATION_SUPPORTED_PREFIXES.has(targetPrefix);

        for (const source of sourceTestimonials) {
            // Check if this testimonial already exists for the target publisher
            let targetTestimonial = await prisma.testimonial.findFirst({
                where: {
                    prefix: targetPrefix,
                    name: source.name,
                    testimonial: source.testimonial,
                },
            });

            if (!targetTestimonial) {
                // Create the testimonial for the target publisher
                targetTestimonial = await prisma.testimonial.create({
                    data: {
                        name: source.name,
                        occupation: source.occupation,
                        testimonial: source.testimonial,
                        image: source.image,
                        categoryIds: source.categoryIds || [],
                        prefix: targetPrefix,
                        company: source.company,
                        country: source.country,
                        featured: source.featured ?? false,
                        purpose: source.purpose,
                        status: source.status ?? "ACTIVE",
                    },
                });
                createdCount++;
            } else {
                existingCount++;
            }

            // Sync/upsert the localizations ONLY if the publisher supports localization
            if (supportsLocalization && source.testimonialLocalizations?.length > 0) {
                for (const loc of source.testimonialLocalizations) {
                    await prisma.testimonial_localization.upsert({
                        where: {
                            testimonialId_locale: {
                                testimonialId: targetTestimonial.id,
                                locale: loc.locale,
                            },
                        },
                        update: {
                            testimonial: loc.testimonial,
                            occupation: loc.occupation,
                            purpose: loc.purpose,
                        },
                        create: {
                            testimonialId: targetTestimonial.id,
                            locale: loc.locale,
                            testimonial: loc.testimonial,
                            occupation: loc.occupation,
                            purpose: loc.purpose,
                        },
                    });
                    localizationsSynced++;
                }
            }
        }

        results.push({
            prefix: targetPrefix,
            supportsLocalization,
            created: createdCount,
            alreadyExisted: existingCount,
            localizationsSynced,
        });
    }

    return {
        sourcePrefix: SOURCE_PREFIX,
        sourceTestimonialsCount: sourceTestimonials.length,
        publishersProcessed: results,
    };
}

export async function GET(request) {
    try {
        const summary = await syncTestimonials();
        return NextResponse.json(
            {
                success: true,
                message: "Testimonials and localizations successfully synced across publishers!",
                data: summary,
            },
            { status: 200 }
        );
    } catch (error) {
        console.error("Testimonial sync failed:", error);
        return NextResponse.json(
            {
                success: false,
                error: error.message,
            },
            { status: 500 }
        );
    }
}
